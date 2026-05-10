import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/progress_providers.dart';

/// Animated line + bar combo chart for daily calorie intake.
///
/// Shows:
/// - Bar per day coloured by whether it meets the goal
/// - Horizontal dashed goal line
/// - Tooltip on touch with date + kcal
class CalorieTrendChart extends StatefulWidget {
  const CalorieTrendChart({
    super.key,
    required this.points,
    required this.calorieGoal,
    required this.range,
  });

  final List<DayCaloriePoint> points;
  final double calorieGoal;
  final ProgressRange range;

  @override
  State<CalorieTrendChart> createState() => _CalorieTrendChartState();
}

class _CalorieTrendChartState extends State<CalorieTrendChart>
    with SingleTickerProviderStateMixin {
  int? _touchedIndex;
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(CalorieTrendChart old) {
    super.didUpdateWidget(old);
    if (old.range != widget.range || old.points != widget.points) {
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isWeekly = widget.range == ProgressRange.weekly;

    final maxY = ([
      widget.calorieGoal * 1.35,
      ...widget.points.map((p) => p.calories),
    ].reduce((a, b) => a > b ? a : b));

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => cs.inverseSurface,
                tooltipRoundedRadius: 10,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final p = widget.points[group.x];
                  return BarTooltipItem(
                    '${DateFormat(isWeekly ? 'EEE d' : 'MMM d').format(p.date)}\n',
                    tt.labelSmall!.copyWith(
                      color: cs.onInverseSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                        text: '${p.calories.toStringAsFixed(0)} kcal',
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onInverseSurface,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  );
                },
              ),
              touchCallback: (event, response) {
                setState(() {
                  _touchedIndex = event.isInterestedForInteractions
                      ? response?.spot?.touchedBarGroupIndex
                      : null;
                });
              },
            ),
            barGroups: widget.points.asMap().entries.map((e) {
              final i = e.key;
              final p = e.value;
              final isTouched = _touchedIndex == i;
              final isOver = p.calories > widget.calorieGoal && p.hasData;
              final isEmpty = !p.hasData;

              final barColor = isEmpty
                  ? cs.surfaceContainerHighest
                  : isOver
                      ? cs.error
                      : cs.primary;

              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: isEmpty
                        ? 0
                        : (p.calories * _anim.value).clamp(0, maxY),
                    color: isTouched
                        ? barColor.withOpacity(1.0)
                        : barColor.withOpacity(0.8),
                    width: isWeekly ? 24 : 10,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6)),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxY,
                      color: cs.surfaceContainerHighest.withOpacity(0.3),
                    ),
                  ),
                ],
              );
            }).toList(),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    if (i < 0 || i >= widget.points.length) {
                      return const SizedBox();
                    }
                    final d = widget.points[i].date;
                    // Weekly: show every day; Monthly: show every 5th
                    if (!isWeekly && i % 5 != 0) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        isWeekly
                            ? DateFormat('E').format(d)
                            : DateFormat('d').format(d),
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 42,
                  interval: widget.calorieGoal / 4,
                  getTitlesWidget: (value, meta) {
                    if (value == 0) return const SizedBox();
                    return Text(
                      '${(value / 1000).toStringAsFixed(1)}k',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: widget.calorieGoal / 4,
              getDrawingHorizontalLine: (val) => FlLine(
                color: cs.outlineVariant.withOpacity(0.25),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: widget.calorieGoal,
                  color: cs.tertiary.withOpacity(0.7),
                  strokeWidth: 1.5,
                  dashArray: [6, 4],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.only(right: 4, bottom: 2),
                    labelResolver: (_) =>
                        '${widget.calorieGoal.toStringAsFixed(0)} kcal',
                    style: TextStyle(
                      color: cs.tertiary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          swapAnimationDuration: const Duration(milliseconds: 300),
          swapAnimationCurve: Curves.easeInOut,
        );
      },
    );
  }
}
