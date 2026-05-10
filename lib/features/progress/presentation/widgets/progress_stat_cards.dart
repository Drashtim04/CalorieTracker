import 'package:flutter/material.dart';

import '../providers/progress_providers.dart';

/// 2×2 stat card grid for the progress page header.
class ProgressStatCards extends StatelessWidget {
  const ProgressStatCards({super.key, required this.stats});

  final ProgressStats stats;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.7,
      children: [
        _StatCard(
          icon: Icons.local_fire_department_rounded,
          label: 'Daily Avg',
          value: '${stats.avgCalories.toStringAsFixed(0)} kcal',
          sub: 'vs ${stats.goal.toStringAsFixed(0)} goal',
          color: cs.primary,
        ),
        _StatCard(
          icon: Icons.calendar_today_rounded,
          label: 'Days Logged',
          value: stats.daysLogged.toString(),
          sub: 'days with data',
          color: const Color(0xFF6C5CE7),
        ),
        _StatCard(
          icon: Icons.check_circle_outline_rounded,
          label: 'On Target',
          value: '${stats.adherencePct.toStringAsFixed(0)}%',
          sub: '${stats.daysOnTarget}/${stats.daysLogged} days ±10%',
          color: const Color(0xFF4CAF82),
        ),
        _StatCard(
          icon: Icons.bolt_rounded,
          label: 'Total',
          value: _kcalK(stats.totalCalories),
          sub: 'kcal this period',
          color: const Color(0xFFF7B731),
        ),
      ],
    );
  }

  String _kcalK(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });

  final IconData icon;
  final String   label;
  final String   value;
  final String   sub;
  final Color    color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 15),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: tt.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: color,
                  height: 1,
                ),
              ),
              Text(
                sub,
                style: tt.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 10,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Best / Worst day banner ──────────────────────────────────────────────────

class BestWorstDayBanner extends StatelessWidget {
  const BestWorstDayBanner({super.key, required this.stats});

  final ProgressStats stats;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (stats.bestDay == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: _DayBanner(
            label: '🏆 Best Day',
            day: stats.bestDay!,
            color: const Color(0xFF4CAF82),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _DayBanner(
            label: '📉 Lowest Day',
            day: stats.worstDay!,
            color: cs.primary,
          ),
        ),
      ],
    );
  }
}

class _DayBanner extends StatelessWidget {
  const _DayBanner({
    required this.label,
    required this.day,
    required this.color,
  });

  final String label;
  final DayCaloriePoint day;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: tt.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            '${day.calories.toStringAsFixed(0)} kcal',
            style: tt.bodyLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            _fmt(day.date),
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[d.weekday]}, ${months[d.month]} ${d.day}';
  }
}

// ─── Macro summary bar ────────────────────────────────────────────────────────

class MacroSummaryBars extends StatelessWidget {
  const MacroSummaryBars({super.key, required this.stats});

  final ProgressStats stats;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final total = stats.totalProtein + stats.totalCarbs + stats.totalFats;

    if (total == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          _Bar('Protein', stats.totalProtein, total, const Color(0xFF4CAF82)),
          const SizedBox(height: 10),
          _Bar('Carbs',   stats.totalCarbs,   total, const Color(0xFFF7B731)),
          const SizedBox(height: 10),
          _Bar('Fats',    stats.totalFats,    total, const Color(0xFFE17055)),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar(this.label, this.value, this.total, this.color);

  final String label;
  final double value;
  final double total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (value / total * 100) : 0.0;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(label,
              style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: total > 0 ? value / total : 0),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                backgroundColor: color.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 10,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 38,
          child: Text(
            '${pct.toStringAsFixed(0)}%',
            style: tt.bodySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
