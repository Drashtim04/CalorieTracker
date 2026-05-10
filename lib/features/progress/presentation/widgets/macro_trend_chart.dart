import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../providers/progress_providers.dart';

/// Animated line chart for macronutrient trend over the range.
///
/// Shows three lines: protein (green), carbs (amber), fats (coral).
class MacroTrendChart extends StatefulWidget {
  const MacroTrendChart({
    super.key,
    required this.points,
    required this.range,
  });

  final List<DayCaloriePoint> points;
  final ProgressRange range;

  @override
  State<MacroTrendChart> createState() => _MacroTrendChartState();
}

class _MacroTrendChartState extends State<MacroTrendChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  static const _protein = Color(0xFF4CAF82);
  static const _carbs   = Color(0xFFF7B731);
  static const _fats    = Color(0xFFE17055);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(MacroTrendChart old) {
    super.didUpdateWidget(old);
    if (old.range != widget.range) {
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

  LineChartBarData _line(
    List<FlSpot> spots,
    Color color,
  ) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.35,
      color: color,
      barWidth: 2.5,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: widget.range == ProgressRange.weekly,
        getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
          radius: 4,
          color: color,
          strokeColor: Colors.white,
          strokeWidth: 1.5,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.06),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isWeekly = widget.range == ProgressRange.weekly;

    final maxMacro = widget.points
        .expand((p) => [p.protein, p.carbs, p.fats])
        .fold(1.0, (a, b) => a > b ? a : b);

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        List<FlSpot> makeSpots(double Function(DayCaloriePoint) fn) {
          return widget.points.asMap().entries.map((e) {
            final v = fn(e.value) * _anim.value;
            return FlSpot(e.key.toDouble(), v);
          }).toList();
        }

        return LineChart(
          LineChartData(
            minY: 0,
            maxY: maxMacro * 1.2,
            lineBarsData: [
              _line(makeSpots((p) => p.protein), _protein),
              _line(makeSpots((p) => p.carbs),   _carbs),
              _line(makeSpots((p) => p.fats),     _fats),
            ],
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 26,
                  interval: isWeekly ? 1 : 5,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    if (i < 0 || i >= widget.points.length) {
                      return const SizedBox();
                    }
                    if (!isWeekly && i % 5 != 0) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        isWeekly
                            ? _shortDay(widget.points[i].date)
                            : '${i + 1}',
                        style: tt.labelSmall
                            ?.copyWith(color: cs.onSurfaceVariant, fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  interval: maxMacro / 4,
                  getTitlesWidget: (value, meta) {
                    if (value == 0) return const SizedBox();
                    return Text(
                      '${value.toStringAsFixed(0)}g',
                      style: tt.labelSmall
                          ?.copyWith(color: cs.onSurfaceVariant, fontSize: 10),
                    );
                  },
                ),
              ),
              topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (val) => FlLine(
                color: cs.outlineVariant.withOpacity(0.22),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => cs.inverseSurface,
                tooltipRoundedRadius: 10,
                getTooltipItems: (spots) {
                  const labels = ['Protein', 'Carbs', 'Fats'];
                  const colors = [_protein, _carbs, _fats];
                  return spots.asMap().entries.map((e) {
                    final i = e.key.clamp(0, 2);
                    return LineTooltipItem(
                      '${labels[i]}: ${e.value.y.toStringAsFixed(1)}g',
                      TextStyle(
                        color: colors[i],
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ),
          duration: const Duration(milliseconds: 300),
        );
      },
    );
  }

  String _shortDay(DateTime d) {
    const days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return days[d.weekday - 1];
  }
}
