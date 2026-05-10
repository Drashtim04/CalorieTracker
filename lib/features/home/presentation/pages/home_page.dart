import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/calorie_ring_widget.dart';
import '../widgets/macro_summary_card.dart';
import '../widgets/macro_donut_chart.dart';
import '../widgets/meal_section_preview.dart';
import '../widgets/quick_stats_row.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dashboardDataProvider);
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // ── Hero App Bar ─────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            snap: true,
            backgroundColor: cs.surface,
            surfaceTintColor: Colors.transparent,
            title: _GreetingTitle(now: now),
            actions: [
              IconButton(
                icon: Badge(
                  isLabelVisible: false,
                  child: const Icon(Icons.notifications_outlined),
                ),
                onPressed: () {},
                tooltip: 'Notifications',
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.push(AppRoutes.goals),
                tooltip: 'Goals & Settings',
              ),
            ],
          ),

          // ── Body ─────────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Hero calorie ring card ─────────────────────────────────────
                _HeroCalorieCard(data: data),
                const SizedBox(height: 16),

                // ── Quick stats row ────────────────────────────────────────────
                const QuickStatsRow(),
                const SizedBox(height: 16),

                // ── Macro breakdown section ────────────────────────────────────
                _SectionHeader(
                  title: 'Macro Breakdown',
                  trailing: _MacroDonutSummary(data: data),
                ),
                const SizedBox(height: 10),
                _MacroGrid(data: data),
                const SizedBox(height: 20),

                // ── Meal preview strip ─────────────────────────────────────────
                const MealPreviewStrip(),
                const SizedBox(height: 20),

                // ── Log Food CTA ───────────────────────────────────────────────
                _LogFoodBanner(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Greeting title ───────────────────────────────────────────────────────────

class _GreetingTitle extends StatelessWidget {
  const _GreetingTitle({required this.now});
  final DateTime now;

  String get _greeting {
    final h = now.hour;
    if (h < 12) return 'Good morning ☀️';
    if (h < 17) return 'Good afternoon 🌤️';
    return 'Good evening 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _greeting,
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        Text(
          DateFormat('EEEE, MMM d').format(now),
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}

// ─── Hero calorie ring card ───────────────────────────────────────────────────

class _HeroCalorieCard extends StatelessWidget {
  const _HeroCalorieCard({required this.data});
  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer.withOpacity(0.55),
            cs.secondaryContainer.withOpacity(0.35),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 360;
          final double ringSize = isSmallScreen ? 140.0 : 180.0;

          final statsColumn = Column(
            crossAxisAlignment: isSmallScreen
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              _RingStat(
                icon: Icons.local_fire_department_rounded,
                label: 'Goal',
                value: '${data.goal.toStringAsFixed(0)} kcal',
                color: cs.primary,
              ),
              const SizedBox(height: 14),
              _RingStat(
                icon: Icons.restaurant_outlined,
                label: 'Consumed',
                value: '${data.consumed.toStringAsFixed(0)} kcal',
                color: const Color(0xFFF7B731),
              ),
              const SizedBox(height: 14),
              _RingStat(
                icon: data.isOverGoal
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline_rounded,
                label: data.isOverGoal ? 'Over by' : 'Remaining',
                value: data.isOverGoal
                    ? '${data.overBy.toStringAsFixed(0)} kcal'
                    : '${data.remaining.toStringAsFixed(0)} kcal',
                color: data.isOverGoal
                    ? cs.error
                    : const Color(0xFF4CAF82),
              ),
              const SizedBox(height: 14),
              // Progress text
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 6, horizontal: 10),
                decoration: BoxDecoration(
                  color: cs.surface.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data.progressPercent.toStringAsFixed(0)}% of daily goal',
                      style: tt.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: data.progress,
                        backgroundColor: cs.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          data.isOverGoal ? cs.error : cs.primary,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          if (isSmallScreen) {
            return Column(
              children: [
                DashboardCalorieRing(
                  consumed: data.consumed,
                  goal: data.goal,
                  ringSize: ringSize,
                  strokeWidth: 14,
                ),
                const SizedBox(height: 24),
                statsColumn,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DashboardCalorieRing(
                consumed: data.consumed,
                goal: data.goal,
                ringSize: ringSize,
                strokeWidth: 16,
              ),
              const SizedBox(width: 20),
              Expanded(child: statsColumn),
            ],
          );
        },
      ),
    );
  }
}

class _RingStat extends StatelessWidget {
  const _RingStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: tt.labelSmall
                    ?.copyWith(color: cs.onSurfaceVariant)),
            Text(value,
                style: tt.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w800)),
          ],
        ),
      ],
    );
  }
}

// ─── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ─── Macro donut inline summary ────────────────────────────────────────────────

class _MacroDonutSummary extends StatelessWidget {
  const _MacroDonutSummary({required this.data});
  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MacroDonutChart(data: data, size: 52),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Legend('P', const Color(0xFF4CAF82),
                '${data.protein.toStringAsFixed(0)}g'),
            _Legend('C', const Color(0xFFF7B731),
                '${data.carbs.toStringAsFixed(0)}g'),
            _Legend('F', const Color(0xFFE17055),
                '${data.fats.toStringAsFixed(0)}g'),
          ],
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend(this.label, this.color, this.value);
  final String label;
  final Color color;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 7,
            height: 7,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text('$label $value',
            style: tt.labelSmall?.copyWith(
                fontWeight: FontWeight.w700, fontSize: 10)),
      ],
    );
  }
}

// ─── Macro 2×2 grid ───────────────────────────────────────────────────────────

class _MacroGrid extends StatelessWidget {
  const _MacroGrid({required this.data});
  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MacroDetailCard(
                label: 'Protein',
                icon: Icons.fitness_center_rounded,
                consumed: data.protein,
                goal: data.proteinGoal,
                color: const Color(0xFF4CAF82),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MacroDetailCard(
                label: 'Carbs',
                icon: Icons.grain_rounded,
                consumed: data.carbs,
                goal: data.carbsGoal,
                color: const Color(0xFFF7B731),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        MacroDetailCard(
          label: 'Fats',
          icon: Icons.water_drop_rounded,
          consumed: data.fats,
          goal: data.fatsGoal,
          color: const Color(0xFFE17055),
        ),
      ],
    );
  }
}

// ─── Log Food CTA ─────────────────────────────────────────────────────────────

class _LogFoodBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final data = ref.watch(dashboardDataProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.consumed == 0
                      ? 'Start logging!'
                      : data.isOverGoal
                          ? 'Goal reached 🎉'
                          : 'Keep it up! 💪',
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.consumed == 0
                      ? 'Log your first meal of the day'
                      : '${data.remaining.toStringAsFixed(0)} kcal remaining today',
                  style: tt.bodySmall
                      ?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: () =>
                GoRouter.of(context).push(AppRoutes.foodSearchNew),
            icon: const Icon(Icons.search_rounded, size: 18),
            label: const Text('Find Food'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: cs.primary,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
