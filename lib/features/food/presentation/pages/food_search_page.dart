import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/food_item.dart';
import '../providers/food_providers.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';

class FoodSearchPage extends ConsumerStatefulWidget {
  const FoodSearchPage({super.key, this.selectionMode = false});

  final bool selectionMode;

  @override
  ConsumerState<FoodSearchPage> createState() => _FoodSearchPageState();
}

class _FoodSearchPageState extends ConsumerState<FoodSearchPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(foodSearchResultsProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.selectionMode ? 'Select Food' : 'Food Database'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Search'),
            Tab(text: 'Favorites'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddFoodDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Food'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              autofocus: widget.selectionMode,
              decoration: const InputDecoration(
                hintText: 'Search food...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (q) {
                ref.read(foodSearchQueryProvider.notifier).state = q;
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Search Tab
                searchResults.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (foods) {
                    if (foods.isEmpty) {
                      return _EmptyState(
                        icon: Icons.search_off_rounded,
                        message: _searchController.text.isEmpty
                            ? 'Your food database is empty.\nTap + to add foods.'
                            : 'No foods found for "${_searchController.text}"',
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: foods.length,
                      itemBuilder: (context, i) => _FoodSearchTile(
                        food: foods[i],
                        selectionMode: widget.selectionMode,
                      ),
                    );
                  },
                ),
                // Favorites Tab
                Consumer(builder: (context, ref, _) {
                  final allFoods =
                      ref.watch(foodListProvider).valueOrNull ?? [];
                  final favorites =
                      allFoods.where((f) => f.isFavorite).toList();
                  if (favorites.isEmpty) {
                    return const _EmptyState(
                      icon: Icons.favorite_border_rounded,
                      message: 'No favorites yet.\nTap ♡ on any food to add.',
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: favorites.length,
                    itemBuilder: (context, i) => _FoodSearchTile(
                      food: favorites[i],
                      selectionMode: widget.selectionMode,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFoodDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _AddFoodBottomSheet(),
    );
  }
}

class _FoodSearchTile extends ConsumerWidget {
  const _FoodSearchTile({
    required this.food,
    required this.selectionMode,
  });

  final FoodItem food;
  final bool selectionMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: () {
          if (selectionMode) {
            Navigator.of(context).pop(food);
          } else {
            context.push('${AppRoutes.foodDetail}/${food.id}');
          }
        },
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: cs.secondaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              food.name.isNotEmpty ? food.name[0].toUpperCase() : '?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSecondaryContainer,
                  ),
            ),
          ),
        ),
        title: Text(
          food.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${food.calories.toStringAsFixed(0)} kcal / '
          '${food.servingSize.toStringAsFixed(0)} ${food.servingUnit}',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: cs.onSurfaceVariant),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selectionMode)
              Icon(Icons.add_circle_rounded, color: cs.primary)
            else
              IconButton(
                icon: Icon(
                  food.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: food.isFavorite ? cs.error : cs.onSurfaceVariant,
                ),
                onPressed: () {
                  ref.read(foodListProvider.notifier).toggleFavorite(food.id);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: cs.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

// ─── Add Food Bottom Sheet ────────────────────────────────────────────────────

class _AddFoodBottomSheet extends ConsumerStatefulWidget {
  const _AddFoodBottomSheet();

  @override
  ConsumerState<_AddFoodBottomSheet> createState() =>
      _AddFoodBottomSheetState();
}

class _AddFoodBottomSheetState extends ConsumerState<_AddFoodBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _servingSizeController = TextEditingController(text: '100');
  final _servingUnitController = TextEditingController(text: 'g');
  String _selectedCategory = AppConstants.foodCategories.first;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _servingSizeController.dispose();
    _servingUnitController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final food = FoodItem(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        category: _selectedCategory,
        servingSize: double.parse(_servingSizeController.text),
        servingUnit: _servingUnitController.text.trim(),
        calories: double.parse(_caloriesController.text),
        protein: double.parse(_proteinController.text),
        carbohydrates: double.parse(_carbsController.text),
        fat: double.parse(_fatController.text),
        createdAt: DateTime.now(),
      );
      await ref.read(foodListProvider.notifier).addFoodItem(food);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Add Food',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        )),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Food Name *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: AppConstants.foodCategories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _selectedCategory = v ?? _selectedCategory),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _servingSizeController,
                    decoration:
                        const InputDecoration(labelText: 'Serving Size *'),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        double.tryParse(v ?? '') == null ? 'Invalid' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _servingUnitController,
                    decoration:
                        const InputDecoration(labelText: 'Unit (e.g. g)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _caloriesController,
                    decoration: const InputDecoration(labelText: 'Calories *'),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        double.tryParse(v ?? '') == null ? 'Invalid' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _proteinController,
                    decoration: const InputDecoration(labelText: 'Protein (g) *'),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        double.tryParse(v ?? '') == null ? 'Invalid' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _carbsController,
                    decoration: const InputDecoration(labelText: 'Carbs (g) *'),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        double.tryParse(v ?? '') == null ? 'Invalid' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _fatController,
                    decoration: const InputDecoration(labelText: 'Fat (g) *'),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        double.tryParse(v ?? '') == null ? 'Invalid' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              style:
                  FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add to Database'),
            ),
          ],
        ),
      ),
    );
  }
}
