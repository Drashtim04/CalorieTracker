import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../data/models/meal_type.dart';
import '../../../ai_food/presentation/screens/ai_food_scanner_screen.dart';
import '../providers/daily_log_providers.dart';
import 'logged_food_tile.dart';

/// Expandable card representing one meal section (Breakfast / Lunch / etc.)
class MealSectionCard extends ConsumerWidget {
  const MealSectionCard({super.key, required this.mealType});

  final MealType mealType;

  // ── Meal metadata ──────────────────────────────────────────────────────────

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
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final expanded = ref.watch(expandedMealsProvider).contains(mealType);
    final calories = ref.watch(mealCalorieTotalsProvider)[mealType] ?? 0;
    final itemCount = ref.watch(mealItemCountProvider)[mealType] ?? 0;
    final entries = ref.watch(flatFoodEntriesProvider)[mealType] ?? [];

    final color = _color(mealType);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: expanded
              ? color.withOpacity(0.4)
              : cs.outlineVariant.withOpacity(0.3),
          width: expanded ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // ── Header row ─────────────────────────────────────────────────────
          InkWell(
            onTap: () => toggleMeal(ref, mealType),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
              child: Row(
                children: [
                  // Meal icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_icon(mealType), color: color, size: 22),
                  ),
                  const SizedBox(width: 12),

                  // Meal name + item count
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mealType.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          itemCount == 0
                              ? 'No items'
                              : '$itemCount item${itemCount == 1 ? '' : 's'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),

                  // Calorie total chip
                  if (calories > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Text(
                        '${calories.toStringAsFixed(0)} kcal',
                        style: tt.labelMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ),
                  const SizedBox(width: 6),

                  // AI Scanner button
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.camera_alt_outlined, color: color, size: 18),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AiFoodScannerScreen(targetMealType: mealType),
                        ),
                      );
                    },
                    tooltip: 'Scan ${mealType.label}',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 6),

                  // Add text search button
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add_rounded, color: color, size: 18),
                    ),
                    onPressed: () => context.push(
                      '${AppRoutes.foodSearchNew}'
                      '?mealType=${mealType.label}',
                    ),
                    tooltip: 'Search ${mealType.label} food',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),

                  // Expand/collapse chevron
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expandable body ────────────────────────────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _MealBody(
              entries: entries,
              mealType: mealType,
              color: color,
            ),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
            sizeCurve: Curves.easeInOutCubic,
          ),
        ],
      ),
    );
  }
}

class _MealBody extends StatelessWidget {
  const _MealBody({
    required this.entries,
    required this.mealType,
    required this.color,
  });

  final List<LoggedFoodEntry> entries;
  final MealType mealType;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        Divider(
          height: 1,
          indent: 14,
          endIndent: 14,
          color: cs.outlineVariant.withOpacity(0.3),
        ),
        if (entries.isEmpty)
          // ── Empty placeholder ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Icon(Icons.add_circle_outline_rounded,
                    color: color.withOpacity(0.5), size: 32),
                const SizedBox(height: 8),
                Text(
                  'Tap + to add ${mealType.label.toLowerCase()} foods',
                  style: tt.bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          )
        else
          // ── Food tiles ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              children: entries
                  .map((e) => LoggedFoodTile(key: ValueKey(e), entry: e))
                  .toList(),
            ),
          ),
      ],
    );
  }
}
