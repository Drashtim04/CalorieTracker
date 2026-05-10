import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.dart';
import '../../../../data/models/meal_type.dart';
import '../../../../data/providers/data_providers.dart';
import '../providers/daily_log_providers.dart';
import '../widgets/daily_summary_card.dart';
import '../widgets/meal_section_card.dart';

/// The main daily meal logging screen.
///
/// Shows 4 expandable meal sections, a calorie-ring summary header,
/// and date-navigation controls.
class DailyLogScreen extends ConsumerWidget {
  const DailyLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(mealLogNotifierProvider);
    final selectedDate = ref.watch(selectedLogDateProvider);
    final totals = ref.watch(dailyNutritionTotalsProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: cs.surface,
            surfaceTintColor: Colors.transparent,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Log',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                Text(
                  DateFormat('EEEE, MMMM d').format(selectedDate),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.today_rounded),
                tooltip: 'Jump to today',
                onPressed: () {
                  final now = DateTime.now();
                  ref.read(selectedLogDateProvider.notifier).state =
                      DateTime(now.year, now.month, now.day);
                  ref.read(mealLogNotifierProvider.notifier).reload();
                },
              ),
              IconButton(
                icon: const Icon(Icons.calendar_month_rounded),
                tooltip: 'Pick date',
                onPressed: () => _pickDate(context, ref, selectedDate),
              ),
            ],
          ),

          // ── Date navigation bar ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: _DateNavBar(selectedDate: selectedDate),
          ),

          // ── Summary card ──────────────────────────────────────────────────
          const SliverToBoxAdapter(child: DailySummaryCard()),

          // ── Section label ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Row(
                children: [
                  Text(
                    'Meals',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const Spacer(),
                  // Expand all / Collapse all toggle
                  _ExpandCollapseToggle(),
                ],
              ),
            ),
          ),

          // ── Loading / error states ────────────────────────────────────────
          if (logsAsync.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (logsAsync.hasError)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: cs.error, size: 48),
                    const SizedBox(height: 12),
                    Text('Failed to load logs',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: cs.error)),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () =>
                          ref.read(mealLogNotifierProvider.notifier).reload(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // ── 4 Meal sections ─────────────────────────────────────────────
            ...MealType.values.map(
              (type) => SliverToBoxAdapter(
                child: MealSectionCard(mealType: type),
              ),
            ),

            // ── Daily calorie footer ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: _DayTotalsFooter(totals: totals),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ],
      ),

      // ── FAB ──────────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'daily_log_fab',
        onPressed: () => context.push(AppRoutes.foodSearchNew),
        icon: const Icon(Icons.search_rounded),
        label: const Text('Find Food'),
      ),
    );
  }

  Future<void> _pickDate(
      BuildContext context, WidgetRef ref, DateTime current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      ref.read(selectedLogDateProvider.notifier).state = picked;
      ref.read(mealLogNotifierProvider.notifier).reload();
    }
  }
}

// ─── Date nav bar ─────────────────────────────────────────────────────────────

class _DateNavBar extends ConsumerWidget {
  const _DateNavBar({required this.selectedDate});

  final DateTime selectedDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final now = DateTime.now();
    final isToday = selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
    final isFuture = selectedDate.isAfter(now);

    void changeDay(int delta) {
      final next = selectedDate.add(Duration(days: delta));
      if (next.isAfter(now)) return;
      ref.read(selectedLogDateProvider.notifier).state = next;
      ref.read(mealLogNotifierProvider.notifier).reload();
    }

    return Container(
      color: cs.surface,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: () => changeDay(-1),
            tooltip: 'Previous day',
          ),
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (d) {
                if (d.primaryVelocity! > 0) changeDay(-1);
                if (d.primaryVelocity! < 0 && !isToday) changeDay(1);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isToday
                      ? cs.primaryContainer.withOpacity(0.4)
                      : cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      isToday ? 'Today' : DateFormat('EEEE').format(selectedDate),
                      style: tt.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isToday ? cs.primary : cs.onSurface,
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, yyyy').format(selectedDate),
                      style: tt.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right_rounded,
              color: isFuture ? cs.outlineVariant : null,
            ),
            onPressed: isToday ? null : () => changeDay(1),
            tooltip: 'Next day',
          ),
        ],
      ),
    );
  }
}

// ─── Expand / collapse all toggle ─────────────────────────────────────────────

class _ExpandCollapseToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expanded = ref.watch(expandedMealsProvider);
    final allExpanded = expanded.length == MealType.values.length;

    return TextButton.icon(
      onPressed: () {
        ref.read(expandedMealsProvider.notifier).state = allExpanded
            ? {}
            : MealType.values.toSet();
      },
      icon: Icon(
        allExpanded
            ? Icons.unfold_less_rounded
            : Icons.unfold_more_rounded,
        size: 16,
      ),
      label: Text(allExpanded ? 'Collapse all' : 'Expand all'),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ─── Day totals footer ─────────────────────────────────────────────────────────

class _DayTotalsFooter extends StatelessWidget {
  const _DayTotalsFooter({required this.totals});

  final NutritionTotals totals;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (totals.calories == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _FooterStat(
              label: 'Total',
              value: '${totals.calories.toStringAsFixed(0)} kcal',
              color: cs.primary,
            ),
            const SizedBox(width: 12),
            _Divider(),
            const SizedBox(width: 12),
            _FooterStat(
              label: 'Protein',
              value: '${totals.protein.toStringAsFixed(1)} g',
              color: const Color(0xFF4CAF82),
            ),
            const SizedBox(width: 12),
            _Divider(),
            const SizedBox(width: 12),
            _FooterStat(
              label: 'Carbs',
              value: '${totals.carbs.toStringAsFixed(1)} g',
              color: const Color(0xFFF7B731),
            ),
            const SizedBox(width: 12),
            _Divider(),
            const SizedBox(width: 12),
            _FooterStat(
              label: 'Fats',
              value: '${totals.fats.toStringAsFixed(1)} g',
              color: const Color(0xFFE17055),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterStat extends StatelessWidget {
  const _FooterStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.4),
    );
  }
}
