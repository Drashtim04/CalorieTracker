import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers/food_log_providers.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../widgets/food_log_tile.dart';
import '../widgets/date_selector_bar.dart';

class FoodLogPage extends ConsumerWidget {
  const FoodLogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(foodLogNotifierProvider);
    final grouped = ref.watch(logsGroupedByMealProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final totals = ref.watch(dailyTotalsProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Log'),
        actions: [
          IconButton(
            onPressed: () => _showDatePicker(context, ref, selectedDate),
            icon: const Icon(Icons.calendar_today_outlined),
            tooltip: 'Pick date',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: DateSelectorBar(selectedDate: selectedDate),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.foodSearchNew),
        icon: const Icon(Icons.search_rounded),
        label: const Text('Find Food'),
      ),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: TextStyle(color: cs.error)),
        ),
        data: (_) => CustomScrollView(
          slivers: [
            // Daily summary header
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SummaryChip(
                      label: 'Calories',
                      value: totals.calories.toStringAsFixed(0),
                      unit: 'kcal',
                    ),
                    _SummaryChip(
                      label: 'Protein',
                      value: totals.protein.toStringAsFixed(1),
                      unit: 'g',
                    ),
                    _SummaryChip(
                      label: 'Carbs',
                      value: totals.carbohydrates.toStringAsFixed(1),
                      unit: 'g',
                    ),
                    _SummaryChip(
                      label: 'Fat',
                      value: totals.fat.toStringAsFixed(1),
                      unit: 'g',
                    ),
                  ],
                ),
              ),
            ),
            // Meal sections
            if (grouped.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restaurant_menu_outlined,
                          size: 64, color: cs.onSurfaceVariant),
                      const SizedBox(height: 16),
                      Text(
                        'No food logged yet',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap + to add your first meal',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...AppConstants.mealTypes.map((mealType) {
                final logs = grouped[mealType];
                if (logs == null || logs.isEmpty) return const SliverToBoxAdapter();
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverMainAxisGroup(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 4),
                          child: Row(
                            children: [
                              Text(
                                mealType,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const Spacer(),
                              Text(
                                '${logs.fold(0.0, (s, l) => s + l.calories).toStringAsFixed(0)} kcal',
                                style:
                                    Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: cs.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () => context.push(
                                    '${AppRoutes.addFoodLog}?mealType=$mealType'),
                                child: Icon(Icons.add_circle_outline,
                                    size: 20, color: cs.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverList.builder(
                        itemCount: logs.length,
                        itemBuilder: (context, i) => FoodLogTile(log: logs[i]),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    ],
                  ),
                );
              }),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Future<void> _showDatePicker(
      BuildContext context, WidgetRef ref, DateTime current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      ref.read(foodLogNotifierProvider.notifier).refreshForDate(picked);
    }
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        Text(
          '$label ($unit)',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
