import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/meal_type.dart';
import '../providers/food_search_providers.dart';

/// Bottom sheet that shows all items in the cart for review/removal.
class CartReviewSheet extends ConsumerWidget {
  const CartReviewSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const CartReviewSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(mealCartProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  Text('Meal Cart',
                      style: tt.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const Spacer(),
                  // Meal type selector
                  DropdownButton<MealType>(
                    value: cart.mealType,
                    underline: const SizedBox(),
                    borderRadius: BorderRadius.circular(12),
                    items: MealType.values
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.label,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        ref.read(mealCartProvider.notifier).setMealType(v);
                      }
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Items list
            Expanded(
              child: cart.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_outlined,
                              size: 48, color: cs.onSurfaceVariant),
                          const SizedBox(height: 12),
                          Text('Cart is empty',
                              style: tt.bodyLarge?.copyWith(
                                  color: cs.onSurfaceVariant)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: cart.entries.length,
                      itemBuilder: (_, i) {
                        final entry = cart.entries[i];
                        final scaled = entry.scaled;
                        return Dismissible(
                          key: Key(entry.food.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: cs.errorContainer,
                            child: Icon(Icons.delete_rounded,
                                color: cs.onErrorContainer),
                          ),
                          onDismissed: (_) => ref
                              .read(mealCartProvider.notifier)
                              .removeAt(i),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: cs.primaryContainer,
                              child: Text(
                                entry.food.name[0].toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: cs.onPrimaryContainer,
                                ),
                              ),
                            ),
                            title: Text(
                              entry.food.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(
                              '${entry.quantity.toStringAsFixed(0)} g  ·  '
                              '${scaled.calories.toStringAsFixed(0)} kcal  '
                              'P${scaled.protein.toStringAsFixed(1)}  '
                              'C${scaled.carbs.toStringAsFixed(1)}  '
                              'F${scaled.fats.toStringAsFixed(1)}',
                              style: tt.bodySmall,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              onPressed: () {
                                Navigator.pop(context);
                                // Re-open quantity sheet to update
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Totals footer
            if (!cart.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  border: Border(
                      top: BorderSide(
                          color: cs.outlineVariant.withOpacity(0.4))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Total('Calories',
                        '${cart.totalCalories.toStringAsFixed(0)} kcal',
                        cs.primary),
                    _Total('Protein',
                        '${cart.totalProtein.toStringAsFixed(1)} g',
                        const Color(0xFF4CAF82)),
                    _Total('Carbs',
                        '${cart.totalCarbs.toStringAsFixed(1)} g',
                        const Color(0xFFF7B731)),
                    _Total('Fats',
                        '${cart.totalFats.toStringAsFixed(1)} g',
                        const Color(0xFFE17055)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Total extends StatelessWidget {
  const _Total(this.label, this.value, this.color);

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w800, color: color)),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
