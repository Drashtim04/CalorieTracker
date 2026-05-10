import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/dashboard_providers.dart';

/// A row of 3 quick-stat chips: Net Calories, Burned, Meals Logged.
class QuickStatsRow extends ConsumerWidget {
  const QuickStatsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dashboardDataProvider);
    final burn = ref.watch(estimatedBurnProvider);
    final net = burn - data.consumed;
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _StatChip(
            icon: Icons.bolt_rounded,
            label: 'Net',
            value: net >= 0
                ? '+${net.toStringAsFixed(0)}'
                : net.toStringAsFixed(0),
            color: net >= 0
                ? const Color(0xFF4CAF82)
                : cs.error,
            subtitle: 'kcal',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatChip(
            icon: Icons.local_fire_department_rounded,
            label: 'Burned',
            value: burn.toStringAsFixed(0),
            color: const Color(0xFFE17055),
            subtitle: 'kcal est.',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatChip(
            icon: Icons.restaurant_rounded,
            label: 'Meals',
            value: data.mealBreakdown.length.toString(),
            color: const Color(0xFF6C5CE7),
            subtitle: 'logged',
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.subtitle,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: cs.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: tt.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
              height: 1,
            ),
          ),
          Text(
            subtitle,
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
