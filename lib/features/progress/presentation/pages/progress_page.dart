import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/progress_providers.dart';
import '../widgets/calorie_trend_chart.dart';
import '../widgets/macro_trend_chart.dart';
import '../widgets/weight_trend_chart.dart';
import '../widgets/progress_stat_cards.dart';

class ProgressPage extends ConsumerStatefulWidget {
  const ProgressPage({super.key});

  @override
  ConsumerState<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends ConsumerState<ProgressPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final range = ref.watch(progressRangeProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          // ── App bar ─────────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: cs.surface,
            surfaceTintColor: Colors.transparent,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progress',
                  style: tt.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                Text(
                  range == ProgressRange.weekly
                      ? 'Last 7 days'
                      : 'Last 30 days',
                  style: tt.bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
            actions: [
              // ── Weekly / Monthly toggle ─────────────────────────────────────
              Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: ProgressRange.values.map((r) {
                    final selected = range == r;
                    return GestureDetector(
                      onTap: () => ref
                          .read(progressRangeProvider.notifier)
                          .state = r,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected ? cs.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          r == ProgressRange.weekly ? '7d' : '30d',
                          style: tt.labelMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: selected
                                ? cs.onPrimary
                                : cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            // ── Tab bar ──────────────────────────────────────────────────────
            bottom: TabBar(
              controller: _tabCtrl,
              tabs: const [
                Tab(icon: Icon(Icons.bar_chart_rounded, size: 18),
                    text: 'Calories'),
                Tab(icon: Icon(Icons.pie_chart_outline_rounded, size: 18),
                    text: 'Macros'),
                Tab(icon: Icon(Icons.monitor_weight_outlined, size: 18),
                    text: 'Weight'),
              ],
              indicatorColor: cs.primary,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 12),
              unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            // ── Tab 1: Calories ──────────────────────────────────────────────
            _CalorieTab(),
            // ── Tab 2: Macros ────────────────────────────────────────────────
            _MacroTab(),
            // ── Tab 3: Weight ────────────────────────────────────────────────
            _WeightTab(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 1 — Calories
// ─────────────────────────────────────────────────────────────────────────────

class _CalorieTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range  = ref.watch(progressRangeProvider);
    final stats  = ref.watch(progressStatsProvider);
    final points = ref.watch(dailyCaloriePointsProvider);
    final logsAsync = ref.watch(rangeLogsProvider);

    return logsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:   (e, _) => _ErrorView(error: e.toString()),
      data:    (_) => _CalorieContent(
        range: range,
        stats: stats,
        points: points,
      ),
    );
  }
}

class _CalorieContent extends StatelessWidget {
  const _CalorieContent({
    required this.range,
    required this.stats,
    required this.points,
  });

  final ProgressRange range;
  final ProgressStats stats;
  final List<DayCaloriePoint> points;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat cards
          ProgressStatCards(stats: stats),
          const SizedBox(height: 16),

          // Best / worst
          BestWorstDayBanner(stats: stats),
          const SizedBox(height: 20),

          // Chart card
          _ChartCard(
            title: 'Calorie Intake',
            subtitle: range == ProgressRange.weekly
                ? 'Last 7 days'
                : 'Last 30 days',
            legend: _Legend([
              _LegendItem(cs.primary, 'On Track'),
              _LegendItem(cs.error,   'Over Goal'),
            ]),
            chart: SizedBox(
              height: 220,
              child: CalorieTrendChart(
                points: points,
                calorieGoal: stats.goal,
                range: range,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Weekly macro breakdown
          _SectionTitle('Cumulative Macros'),
          const SizedBox(height: 10),
          MacroSummaryBars(stats: stats),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 2 — Macros
// ─────────────────────────────────────────────────────────────────────────────

class _MacroTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range  = ref.watch(progressRangeProvider);
    final points = ref.watch(dailyCaloriePointsProvider);
    final logsAsync = ref.watch(rangeLogsProvider);

    return logsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:   (e, _) => _ErrorView(error: e.toString()),
      data:    (_) => _MacroContent(range: range, points: points),
    );
  }
}

class _MacroContent extends StatelessWidget {
  const _MacroContent({required this.range, required this.points});

  final ProgressRange range;
  final List<DayCaloriePoint> points;

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Macro line chart
          _ChartCard(
            title: 'Macro Trends',
            subtitle: range == ProgressRange.weekly
                ? 'Last 7 days'
                : 'Last 30 days',
            legend: _Legend([
              const _LegendItem(Color(0xFF4CAF82), 'Protein'),
              const _LegendItem(Color(0xFFF7B731), 'Carbs'),
              const _LegendItem(Color(0xFFE17055), 'Fats'),
            ]),
            chart: SizedBox(
              height: 220,
              child: MacroTrendChart(points: points, range: range),
            ),
          ),
          const SizedBox(height: 20),

          // Per-day macro table
          _SectionTitle('Daily Macro Detail'),
          const SizedBox(height: 10),
          _MacroDayTable(points: points),
        ],
      ),
    );
  }
}

class _MacroDayTable extends StatelessWidget {
  const _MacroDayTable({required this.points});

  final List<DayCaloriePoint> points;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final reversed = [...points.reversed];

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('Date', style: tt.labelSmall?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurfaceVariant))),
                Expanded(flex: 2, child: Text('P', style: tt.labelSmall?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF4CAF82)))),
                Expanded(flex: 2, child: Text('C', style: tt.labelSmall?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFFF7B731)))),
                Expanded(flex: 2, child: Text('F', style: tt.labelSmall?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFFE17055)))),
                Expanded(flex: 2, child: Text('kcal', style: tt.labelSmall?.copyWith(fontWeight: FontWeight.w700, color: cs.primary))),
              ],
            ),
          ),
          Divider(height: 1, color: cs.outlineVariant.withOpacity(0.4)),
          ...reversed.take(14).map((p) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 9),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          DateFormat('E, d MMM').format(p.date),
                          style: tt.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: p.hasData
                                ? cs.onSurface
                                : cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(flex: 2, child: Text(_g(p.protein), style: tt.bodySmall?.copyWith(color: const Color(0xFF4CAF82), fontWeight: FontWeight.w600))),
                      Expanded(flex: 2, child: Text(_g(p.carbs),   style: tt.bodySmall?.copyWith(color: const Color(0xFFF7B731), fontWeight: FontWeight.w600))),
                      Expanded(flex: 2, child: Text(_g(p.fats),    style: tt.bodySmall?.copyWith(color: const Color(0xFFE17055), fontWeight: FontWeight.w600))),
                      Expanded(flex: 2, child: Text(
                        p.hasData ? '${p.calories.toStringAsFixed(0)}' : '—',
                        style: tt.bodySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: p.hasData ? cs.primary : cs.outlineVariant,
                        ),
                      )),
                    ],
                  ),
                ),
                if (p != reversed.take(14).last)
                  Divider(
                      height: 1,
                      color: cs.outlineVariant.withOpacity(0.2),
                      indent: 14),
              ],
            );
          }),
        ],
      ),
    );
  }

  String _g(double v) => v > 0 ? '${v.toStringAsFixed(0)}g' : '—';
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 3 — Weight
// ─────────────────────────────────────────────────────────────────────────────

class _WeightTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(weightTrendProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart
          _ChartCard(
            title: 'Weight Trend',
            subtitle: 'Track your body weight over time',
            legend: const _Legend([
              _LegendItem(Color(0xFF6C5CE7), 'Weight (kg)'),
            ]),
            chart: SizedBox(
              height: 220,
              child: WeightTrendChart(
                entries: entries,
                onAddWeight: () => _showAddWeightSheet(context, ref),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Add weight button
          if (entries.isNotEmpty)
            OutlinedButton.icon(
              onPressed: () => _showAddWeightSheet(context, ref),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Log Today\'s Weight'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),

          if (entries.isNotEmpty) ...[
            const SizedBox(height: 20),
            _SectionTitle('Weight History'),
            const SizedBox(height: 10),
            _WeightHistoryList(entries: entries),
          ],
        ],
      ),
    );
  }

  void _showAddWeightSheet(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Log Weight',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Weight',
                suffixText: 'kg',
                prefixIcon: const Icon(Icons.monitor_weight_outlined),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                final kg = double.tryParse(ctrl.text);
                if (kg != null && kg > 0) {
                  final now = DateTime.now();
                  ref.read(weightLogProvider.notifier).update(
                        (s) => [
                          ...s,
                          WeightEntry(
                            date: DateTime(now.year, now.month, now.day),
                            kg: kg,
                          ),
                        ],
                      );
                }
                Navigator.pop(ctx);
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: const Color(0xFF6C5CE7),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeightHistoryList extends StatelessWidget {
  const _WeightHistoryList({required this.entries});

  final List<WeightEntry> entries;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final reversed = [...entries.reversed];

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        children: reversed.asMap().entries.map((e) {
          final entry = e.value;
          final prev = e.key < reversed.length - 1
              ? reversed[e.key + 1]
              : null;
          final delta = prev != null ? entry.kg - prev.kg : null;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C5CE7).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.monitor_weight_outlined,
                          color: Color(0xFF6C5CE7), size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        DateFormat('EEE, MMM d').format(entry.date),
                        style: tt.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (delta != null)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: delta > 0
                              ? cs.errorContainer
                              : const Color(0xFF4CAF82).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${delta > 0 ? '+' : ''}${delta.toStringAsFixed(1)}',
                          style: tt.labelSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: delta > 0
                                ? cs.error
                                : const Color(0xFF4CAF82),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    Text(
                      '${entry.kg.toStringAsFixed(1)} kg',
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF6C5CE7),
                      ),
                    ),
                  ],
                ),
              ),
              if (e.key < reversed.length - 1)
                Divider(
                    height: 1,
                    color: cs.outlineVariant.withOpacity(0.25),
                    indent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.legend,
    required this.chart,
  });

  final String  title;
  final String  subtitle;
  final Widget  legend;
  final Widget  chart;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: tt.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w900)),
                    Text(subtitle,
                        style: tt.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              legend,
            ],
          ),
          const SizedBox(height: 16),
          chart,
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend(this.items);
  final List<_LegendItem> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: items,
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem(this.color, this.label);

  final Color  color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 8,
            height: 8,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label,
            style: tt.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 10,
            )),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .titleSmall
          ?.copyWith(fontWeight: FontWeight.w900),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: cs.error, size: 48),
          const SizedBox(height: 12),
          Text(error,
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.error)),
        ],
      ),
    );
  }
}
