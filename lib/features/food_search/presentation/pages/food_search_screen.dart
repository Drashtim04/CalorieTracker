import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../data/dummy/dummy_foods.dart';
import '../../../../data/models/food_model.dart';
import '../../../../data/models/meal_type.dart';
import '../../../../data/providers/data_providers.dart';
import '../../../ai_food/presentation/screens/ai_food_scanner_screen.dart';
import '../providers/food_search_providers.dart';
import '../providers/smart_suggestions_provider.dart';
import '../widgets/cart_review_sheet.dart';
import '../widgets/food_result_tile.dart';
import '../widgets/meal_cart_bar.dart';

/// Full-page food search screen.
///
/// Entry points:
///   - Log tab FAB → `context.push(AppRoutes.foodSearch)`
///   - Home "Log Food" quick action
///
/// On "Save Meal" the cart is persisted as a [MealLogModel] and the screen pops.
class FoodSearchScreen extends ConsumerStatefulWidget {
  const FoodSearchScreen({super.key, this.initialMealType});

  /// Pre-select a meal type (e.g. when launched from a specific meal section).
  final MealType? initialMealType;

  @override
  ConsumerState<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends ConsumerState<FoodSearchScreen> {
  late final TextEditingController _searchCtrl;
  final FocusNode _searchFocus = FocusNode();
  bool _isSaving = false;
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();

    // Set initial meal type on the cart
    if (widget.initialMealType != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(mealCartProvider.notifier)
            .setMealType(widget.initialMealType!);
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _showScanOptions() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AiFoodScannerScreen()),
    );
  }

  Future<void> _saveMeal() async {
    if (ref.read(mealCartProvider).isEmpty) return;
    setState(() => _isSaving = true);
    try {
      // buildMeal creates the model + clears cart without touching Hive
      final log = ref.read(mealCartProvider.notifier).buildMeal();
      // Single write: add() persists to Hive AND triggers UI refresh
      await ref.read(mealLogNotifierProvider.notifier).add(log);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${log.mealType.label} saved — '
              '${log.totalCalories.toStringAsFixed(0)} kcal',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF4CAF82),
          ),
        );
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final results = ref.watch(filteredFoodsProvider);
    final query = ref.watch(searchQueryProvider);
    final cart = ref.watch(mealCartProvider);
    final suggestions = ref.watch(smartSuggestionsProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        titleSpacing: 0,
        title: _SearchBar(
          controller: _searchCtrl, 
          focusNode: _searchFocus,
          isDetecting: _isDetecting,
          onScanPressed: _showScanOptions,
        ),
        actions: [
          if (cart.count > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Badge(
                label: Text('${cart.count}'),
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () => CartReviewSheet.show(context),
                  tooltip: 'Review cart',
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Meal type selector ──────────────────────────────────────────────
          _MealTypeSelector(),

          // ── Category filter chips ───────────────────────────────────────────
          _CategoryChips(),

          // ── Smart Suggestions ───────────────────────────────────────────────
          if (query.isEmpty && suggestions.isNotEmpty)
            _SmartSuggestionsList(suggestions: suggestions),

          // ── Results count ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
            child: Row(
              children: [
                Text(
                  query.isEmpty
                      ? '${results.length} foods'
                      : '${results.length} results for "$query"',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                const Spacer(),
                if (results.isEmpty && query.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      _searchCtrl.clear();
                      ref
                          .read(searchQueryProvider.notifier)
                          .state = '';
                    },
                    icon: const Icon(Icons.clear, size: 14),
                    label: const Text('Clear'),
                  ),
              ],
            ),
          ),

          // ── Results list ────────────────────────────────────────────────────
          Expanded(
            child: results.isEmpty
                ? _EmptyState(query: query)
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 120, top: 4),
                    itemCount: results.length,
                    itemBuilder: (_, i) =>
                        FoodResultTile(food: results[i]),
                  ),
          ),
        ],
      ),

      // ── Sticky cart bar ─────────────────────────────────────────────────────
      bottomNavigationBar: MealCartBar(
        onSave: _isSaving ? () {} : _saveMeal,
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _SearchBar extends ConsumerStatefulWidget {
  const _SearchBar({
    required this.controller, 
    required this.focusNode,
    required this.isDetecting,
    required this.onScanPressed,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isDetecting;
  final VoidCallback onScanPressed;

  @override
  ConsumerState<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<_SearchBar> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).state = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        autofocus: true,
        onChanged: _onSearchChanged,
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: 'Search foods…',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    widget.controller.clear();
                    ref.read(searchQueryProvider.notifier).state = '';
                  },
                ),
              if (widget.isDetecting)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.document_scanner_outlined, color: Color(0xFF6C5CE7)),
                  tooltip: 'Scan food',
                  onPressed: widget.onScanPressed,
                ),
            ],
          ),
          filled: true,
          fillColor: cs.surfaceContainerLow,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _MealTypeSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(mealCartProvider);
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Meal:',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(width: 2),
          ...MealType.values.map((type) {
            final selected = cart.mealType == type;
            return ChoiceChip(
              label: Text(type.label),
              selected: selected,
              onSelected: (_) =>
                  ref.read(mealCartProvider.notifier).setMealType(type),
              labelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? cs.onPrimaryContainer : null,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CategoryChips extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: AppConstants.foodCategories.length + 1,
        itemBuilder: (context, i) {
          final cat = i == 0 ? 'All' : AppConstants.foodCategories[i - 1];
          final selected = selectedCategory == cat || (i == 0 && selectedCategory == null);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat),
              selected: selected,
              onSelected: (_) => ref.read(selectedCategoryProvider.notifier).state = i == 0 ? 'All' : cat,
            ),
          );
        },
      ),
    );
  }
}

class _SmartSuggestionsList extends ConsumerWidget {
  const _SmartSuggestionsList({required this.suggestions});
  final List<FoodModel> suggestions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Icon(Icons.auto_awesome_rounded, size: 16, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                'Smart Suggestions',
                style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.primary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final food = suggestions[index];
              return Container(
                width: 140,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${food.calories.toStringAsFixed(0)} kcal',
                        style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                      const Spacer(),
                      SizedBox(
                        height: 32,
                        width: double.infinity,
                        child: FilledButton.tonalIcon(
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            ref.read(mealCartProvider.notifier).addFood(food, 100);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added ${food.name}'),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text('Add', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: cs.outlineVariant),
            const SizedBox(height: 16),
            Text(
              query.isEmpty
                  ? 'No foods in this category'
                  : 'No results for "$query"',
              style:
                  tt.titleMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term or category',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
