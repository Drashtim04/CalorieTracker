import 'package:flutter/material.dart';

/// A rich macro card showing consumed vs goal with an animated progress bar
/// and a donut-style indicator arc.
class MacroDetailCard extends StatelessWidget {
  const MacroDetailCard({
    super.key,
    required this.label,
    required this.icon,
    required this.consumed,
    required this.goal,
    required this.color,
  });

  final String label;
  final IconData icon;
  final double consumed;
  final double goal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final progress = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
    final remaining = (goal - consumed).clamp(0.0, double.infinity);
    final isOver = consumed > goal && goal > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
              const Spacer(),
              // Badge: over / on track
              if (goal > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isOver
                        ? cs.errorContainer
                        : color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isOver
                        ? '+${(consumed - goal).toStringAsFixed(0)}g'
                        : '${(progress * 100).toStringAsFixed(0)}%',
                    style: tt.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isOver ? cs.onErrorContainer : color,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Consumed value ─────────────────────────────────────────────────
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 4,
            runSpacing: 2,
            children: [
              Text(
                consumed.toStringAsFixed(1),
                style: tt.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: color,
                  height: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '/ ${goal.toStringAsFixed(0)} g',
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            goal > 0
                ? '${remaining.toStringAsFixed(1)} g remaining'
                : 'No goal set',
            style: tt.labelSmall
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),

          // ── Progress bar ───────────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
