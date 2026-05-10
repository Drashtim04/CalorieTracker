import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../data/models/meal_type.dart';
import '../../../../data/providers/data_providers.dart';

/// Horizontal strip of 4 meal preview tiles.
class MealPreviewStrip extends ConsumerWidget {
  const MealPreviewStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped = ref.watch(logsByMealTypeProvider);
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
          child: Row(
            children: [
              Text(
                "Today's Meals",
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.go(AppRoutes.log),
                child: const Text('See all'),
              ),
            ],
          ),
        ),
        Row(
          children: MealType.values.map((type) {
            final logs = grouped[type] ?? [];
            final kcal = logs.fold<double>(0, (s, l) => s + l.totalCalories);
            final count = logs.fold<int>(0, (s, l) => s + l.foods.length);
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: type != MealType.snack ? 8 : 0,
                ),
                child: _MealTile(
                  type: type,
                  kcal: kcal,
                  itemCount: count,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _MealTile extends StatelessWidget {
  const _MealTile({
    required this.type,
    required this.kcal,
    required this.itemCount,
  });

  final MealType type;
  final double kcal;
  final int itemCount;

  static IconData _icon(MealType t) {
    switch (t) {
      case MealType.breakfast: return Icons.wb_sunny_rounded;
      case MealType.lunch:     return Icons.restaurant_rounded;
      case MealType.dinner:    return Icons.nightlight_rounded;
      case MealType.snack:     return Icons.cookie_rounded;
    }
  }

  static Color _color(MealType t) {
    switch (t) {
      case MealType.breakfast: return const Color(0xFFFDCB6E);
      case MealType.lunch:     return const Color(0xFF4CAF82);
      case MealType.dinner:    return const Color(0xFF6C5CE7);
      case MealType.snack:     return const Color(0xFFE17055);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = _color(type);
    final hasFood = itemCount > 0;

    return InkWell(
      onTap: () => GoRouter.of(context).push(
        '${AppRoutes.foodSearchNew}?mealType=${type.label}',
      ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: hasFood
              ? color.withOpacity(0.1)
              : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasFood
                ? color.withOpacity(0.3)
                : cs.outlineVariant.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              _icon(type),
              color: hasFood ? color : cs.onSurfaceVariant,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              type.label,
              style: tt.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: hasFood ? cs.onSurface : cs.onSurfaceVariant,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              hasFood ? '${kcal.toStringAsFixed(0)}\nkcal' : '+\nadd',
              style: tt.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: hasFood ? color : cs.onSurfaceVariant,
                fontSize: 9,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
