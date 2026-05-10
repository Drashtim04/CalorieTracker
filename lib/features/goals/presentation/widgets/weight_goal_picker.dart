import 'package:flutter/material.dart';

import '../../domain/entities/nutrition_goal.dart';

/// Step 2b — Weight goal selection (lose / maintain / gain).
class WeightGoalPicker extends StatelessWidget {
  const WeightGoalPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final WeightGoal? selected;
  final void Function(WeightGoal) onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    const goalColors = {
      WeightGoal.lose:     Color(0xFF4CAF82),
      WeightGoal.maintain: Color(0xFF6C5CE7),
      WeightGoal.gain:     Color(0xFFE17055),
    };

    const goalIcons = {
      WeightGoal.lose:     Icons.trending_down_rounded,
      WeightGoal.maintain: Icons.trending_flat_rounded,
      WeightGoal.gain:     Icons.trending_up_rounded,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.flag_rounded, color: cs.primary, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Goal',
                    style: tt.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w900)),
                Text('What do you want to achieve?',
                    style: tt.bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 3 goal cards
        Row(
          children: WeightGoal.values.map((g) {
            final isSelected = selected == g;
            final color = goalColors[g]!;
            final icon  = goalIcons[g]!;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    right: g != WeightGoal.gain ? 8 : 0),
                child: InkWell(
                  onTap: () => onChanged(g),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withOpacity(0.12)
                          : cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? color
                            : cs.outlineVariant.withOpacity(0.35),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: color, size: 24),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          g.label,
                          textAlign: TextAlign.center,
                          style: tt.bodySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isSelected ? color : cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          g.description,
                          textAlign: TextAlign.center,
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(height: 8),
                          Icon(Icons.check_circle_rounded,
                              color: color, size: 18),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
