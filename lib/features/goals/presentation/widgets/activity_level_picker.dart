import 'package:flutter/material.dart';

import '../../domain/entities/nutrition_goal.dart';

/// Step 2a — Activity level selection cards.
class ActivityLevelPicker extends StatelessWidget {
  const ActivityLevelPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final ActivityLevel? selected;
  final void Function(ActivityLevel) onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final icons = [
      Icons.chair_rounded,
      Icons.directions_walk_rounded,
      Icons.directions_bike_rounded,
      Icons.fitness_center_rounded,
      Icons.sports_gymnastics_rounded,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(
          icon: Icons.bolt_rounded,
          color: const Color(0xFFF7B731),
          label: 'Activity Level',
          subtitle: 'How active are you on most days?',
        ),
        const SizedBox(height: 12),
        ...ActivityLevel.values.asMap().entries.map((e) {
          final level = e.value;
          final i = e.key;
          final isSelected = selected == level;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => onChanged(level),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFF7B731).withOpacity(0.12)
                      : cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFF7B731)
                        : cs.outlineVariant.withOpacity(0.35),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFF7B731).withOpacity(0.2)
                            : cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icons[i],
                        color: isSelected
                            ? const Color(0xFFF7B731)
                            : cs.onSurfaceVariant,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            level.label,
                            style: tt.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? const Color(0xFFF7B731)
                                  : cs.onSurface,
                            ),
                          ),
                          Text(
                            level.description,
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Multiplier badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFF7B731).withOpacity(0.2)
                            : cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '×${level.multiplier.toStringAsFixed(3)}',
                        style: tt.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? const Color(0xFFF7B731)
                              : cs.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.check_circle_rounded,
                          color: Color(0xFFF7B731), size: 20),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
  });

  final IconData icon;
  final Color    color;
  final String   label;
  final String   subtitle;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    tt.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
            Text(subtitle,
                style: tt.bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      ],
    );
  }
}
