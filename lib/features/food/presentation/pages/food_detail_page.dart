import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/food_providers.dart';
import '../../../../core/router/app_router.dart';

class FoodDetailPage extends ConsumerWidget {
  const FoodDetailPage({super.key, required this.foodId});

  final String foodId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foodAsync = ref.watch(foodItemByIdProvider(foodId));
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Details'),
        actions: [
          foodAsync.valueOrNull != null
              ? IconButton(
                  onPressed: () {
                    ref.read(foodListProvider.notifier).toggleFavorite(foodId);
                  },
                  icon: Icon(
                    foodAsync.value?.isFavorite == true
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: foodAsync.value?.isFavorite == true
                        ? cs.error
                        : null,
                  ),
                )
              : const SizedBox(),
          IconButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Food'),
                  content: const Text(
                      'This will permanently delete this food item. Continue?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel')),
                    FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete')),
                  ],
                ),
              );
              if (confirm == true) {
                await ref
                    .read(foodListProvider.notifier)
                    .deleteFoodItem(foodId);
                if (context.mounted) context.pop();
              }
            },
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: foodAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (food) {
          if (food == null) {
            return const Center(child: Text('Food not found'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        cs.primaryContainer,
                        cs.secondaryContainer,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.name,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: cs.onPrimaryContainer,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        food.category,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: cs.onPrimaryContainer.withOpacity(0.8),
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Per ${food.servingSize.toStringAsFixed(0)} ${food.servingUnit}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: cs.onPrimaryContainer.withOpacity(0.7),
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Calories highlight
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_fire_department_rounded,
                          size: 32),
                      const SizedBox(width: 12),
                      Column(
                        children: [
                          Text(
                            food.calories.toStringAsFixed(0),
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text('Calories',
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Macros
                Text('Macronutrients',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        )),
                const SizedBox(height: 12),
                _NutritionTable([
                  ('Protein', food.protein, 'g', const Color(0xFF4CAF82)),
                  ('Carbohydrates', food.carbohydrates, 'g',
                      const Color(0xFFF7B731)),
                  ('Fat', food.fat, 'g', const Color(0xFFE17055)),
                  ('Fiber', food.fiber, 'g', const Color(0xFF74B9FF)),
                  ('Sugar', food.sugar, 'g', const Color(0xFFFF7675)),
                  ('Sodium', food.sodium, 'mg', const Color(0xFFA29BFE)),
                ]),
                const SizedBox(height: 24),

                // Add to Log Button
                FilledButton.icon(
                  onPressed: () {
                    context.push(
                        '${AppRoutes.addFoodLog}?mealType=Breakfast');
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add to Log'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NutritionTable extends StatelessWidget {
  const _NutritionTable(this.items);

  final List<(String, double, String, Color)> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.4),
        ),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final (label, value, unit, color) = entry.value;
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '${value.toStringAsFixed(1)} $unit',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
              if (i < items.length - 1)
                Divider(
                  height: 1,
                  indent: 32,
                  endIndent: 16,
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withOpacity(0.3),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
