import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/food_model.dart';
import '../../../../data/dummy/dummy_foods.dart';
import '../providers/food_search_providers.dart';
import 'quantity_sheet.dart';

/// A single food item card in the search results list.
class FoodResultTile extends ConsumerWidget {
  const FoodResultTile({super.key, required this.food});

  final FoodModel food;

  // Consistent color per category
  static Color _categoryColor(String cat, ColorScheme cs) {
    switch (cat) {
      case 'Protein':    return const Color(0xFF4CAF82);
      case 'Grains':     return const Color(0xFFF7B731);
      case 'Dairy':      return const Color(0xFF74B9FF);
      case 'Fruits':     return const Color(0xFFFF7675);
      case 'Vegetables': return const Color(0xFF00B894);
      case 'Legumes':    return const Color(0xFFA29BFE);
      case 'Nuts':       return const Color(0xFFE17055);
      case 'Snacks':     return const Color(0xFFFDCB6E);
      case 'Fats':       return const Color(0xFFDFE6E9);
      case 'Sweets':     return const Color(0xFFE84393);
      case 'Drinks':     return const Color(0xFF0984E3);
      default:           return cs.primary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isInCart = ref.watch(isInCartProvider(food.id));
    final category = DummyFoods.categoryFor(food);
    final catColor = _categoryColor(category, cs);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: InkWell(
        onTap: () => QuantitySheet.show(context, ref, food),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // ── Category avatar ────────────────────────────────────────────
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: catColor.withOpacity(0.3), width: 1.5),
                ),
                child: Center(
                  child: Text(
                    food.name[0].toUpperCase(),
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: catColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // ── Name & macro pills ─────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            food.name,
                            style: tt.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isInCart)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: cs.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'In meal',
                              style: tt.labelSmall?.copyWith(
                                color: cs.onPrimaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: [
                        _MacroPill(
                          label: '${food.calories.toStringAsFixed(0)} kcal',
                          color: cs.primary,
                          filled: true,
                        ),
                        _MacroPill(
                          label: 'P ${food.protein.toStringAsFixed(0)}g',
                          color: const Color(0xFF4CAF82),
                        ),
                        _MacroPill(
                          label: 'C ${food.carbs.toStringAsFixed(0)}g',
                          color: const Color(0xFFF7B731),
                        ),
                        _MacroPill(
                          label: 'F ${food.fats.toStringAsFixed(0)}g',
                          color: const Color(0xFFE17055),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'per ${food.quantity.toStringAsFixed(0)} g · $category',
                      style: tt.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),

              // ── Add icon ───────────────────────────────────────────────────
              const SizedBox(width: 8),
              Icon(
                isInCart
                    ? Icons.check_circle_rounded
                    : Icons.add_circle_outline_rounded,
                color: isInCart ? const Color(0xFF4CAF82) : cs.primary,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MacroPill extends StatelessWidget {
  const _MacroPill({
    required this.label,
    required this.color,
    this.filled = false,
  });

  final String label;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: filled ? color.withOpacity(0.15) : color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
