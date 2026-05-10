import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/providers/data_providers.dart';
import '../../../../features/goals/presentation/providers/goals_providers.dart';

/// Animated calorie ring + macro progress bars for the top of the daily log.
class DailySummaryCard extends ConsumerWidget {
  const DailySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totals = ref.watch(dailyNutritionTotalsProvider);
    final goal = ref.watch(currentGoalProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final calorieProgress =
        goal.calorieGoal > 0 ? totals.calories / goal.calorieGoal : 0.0;
    final isOver = calorieProgress > 1.0;
    final ringColor = isOver ? cs.error : cs.primary;
    final remaining = (goal.calorieGoal - totals.calories).clamp(0.0, double.infinity);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer.withOpacity(0.5),
            cs.secondaryContainer.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // ── Calorie ring ────────────────────────────────────────────────────
          SizedBox(
            width: 110,
            height: 110,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(110, 110),
                  painter: _CalorieRingPainter(
                    progress: calorieProgress.clamp(0.0, 1.0),
                    bgColor: cs.surfaceContainerHighest.withOpacity(0.6),
                    fgColor: ringColor,
                    strokeWidth: 10,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      totals.calories.toStringAsFixed(0),
                      style: tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: isOver ? cs.error : cs.onSurface,
                        height: 1,
                      ),
                    ),
                    Text(
                      'kcal',
                      style: tt.labelSmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color:
                            isOver ? cs.errorContainer : cs.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isOver
                            ? '+${(totals.calories - goal.calorieGoal).toStringAsFixed(0)}'
                            : '${remaining.toStringAsFixed(0)} left',
                        style: tt.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isOver
                              ? cs.onErrorContainer
                              : cs.onPrimaryContainer,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),

          // ── Macro progress bars ─────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MacroBar(
                  label: 'Protein',
                  consumed: totals.protein,
                  goal: goal.proteinGoal,
                  color: const Color(0xFF4CAF82),
                ),
                const SizedBox(height: 10),
                _MacroBar(
                  label: 'Carbs',
                  consumed: totals.carbs,
                  goal: goal.carbsGoal,
                  color: const Color(0xFFF7B731),
                ),
                const SizedBox(height: 10),
                _MacroBar(
                  label: 'Fats',
                  consumed: totals.fats,
                  goal: goal.fatGoal,
                  color: const Color(0xFFE17055),
                ),
                const SizedBox(height: 10),
                // Goal callout
                Text(
                  'Goal: ${goal.calorieGoal.toStringAsFixed(0)} kcal',
                  style: tt.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  const _MacroBar({
    required this.label,
    required this.consumed,
    required this.goal,
    required this.color,
  });

  final String label;
  final double consumed;
  final double goal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: tt.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700, color: color)),
            Text(
              '${consumed.toStringAsFixed(0)} / ${goal.toStringAsFixed(0)} g',
              style: tt.labelSmall?.copyWith(
                color:
                    Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _CalorieRingPainter extends CustomPainter {
  const _CalorieRingPainter({
    required this.progress,
    required this.bgColor,
    required this.fgColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color bgColor;
  final Color fgColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bgPaint = Paint()
      ..color = bgColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = fgColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Background arc
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi, false, bgPaint);

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
          rect, -math.pi / 2, 2 * math.pi * progress, false, fgPaint);
    }
  }

  @override
  bool shouldRepaint(_CalorieRingPainter old) =>
      old.progress != progress || old.fgColor != fgColor;
}
