import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/progress_providers.dart';

/// Optional weight trend line chart.
///
/// Shows a smooth line connecting [WeightEntry] points.
/// Displays an empty state with a log-weight FAB when no entries exist.
class WeightTrendChart extends StatefulWidget {
  const WeightTrendChart({
    super.key,
    required this.entries,
    required this.onAddWeight,
  });

  final List<WeightEntry> entries;
  final VoidCallback onAddWeight;

  @override
  State<WeightTrendChart> createState() => _WeightTrendChartState();
}

class _WeightTrendChartState extends State<WeightTrendChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    if (widget.entries.isNotEmpty) _ctrl.forward();
  }

  @override
  void didUpdateWidget(WeightTrendChart old) {
    super.didUpdateWidget(old);
    if (old.entries.length != widget.entries.length) {
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

    if (widget.entries.isEmpty) {
      return _EmptyWeightState(onAdd: widget.onAddWeight);
    }

    final weights = widget.entries.map((e) => e.kg).toList();
    final minW = weights.reduce((a, b) => a < b ? a : b) - 1;
    final maxW = weights.reduce((a, b) => a > b ? a : b) + 1;

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final spots = widget.entries.asMap().entries.map((e) {
          return FlSpot(e.key.toDouble(), e.value.kg);
        }).toList();

        return LineChart(
          LineChartData(
            minY: minW,
            maxY: maxW,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.4,
                color: const Color(0xFF6C5CE7),
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                    radius: 5,
                    color: const Color(0xFF6C5CE7),
                    strokeColor: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF6C5CE7).withOpacity(0.2),
                      const Color(0xFF6C5CE7).withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ],
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    if (i < 0 || i >= widget.entries.length) {
                      return const SizedBox();
                    }
                    // Show every other label
                    if (widget.entries.length > 7 && i % 2 != 0) {
                      return const SizedBox();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        DateFormat('d/M').format(widget.entries[i].date),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toStringAsFixed(1)}',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 10,
                      ),
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
                getTooltipItems: (spots) => spots.map((s) {
                  final i = s.x.toInt().clamp(0, widget.entries.length - 1);
                  final e = widget.entries[i];
                  return LineTooltipItem(
                    '${DateFormat('MMM d').format(e.date)}\n',
                    TextStyle(
                      color: cs.onInverseSurface,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                        text: '${e.kg.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                          color: Color(0xFF6C5CE7),
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          duration: const Duration(milliseconds: 300),
        );
      },
    );
  }
}

class _EmptyWeightState extends StatelessWidget {
  const _EmptyWeightState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.monitor_weight_outlined,
            size: 52, color: cs.outlineVariant),
        const SizedBox(height: 12),
        Text(
          'No weight entries yet',
          style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Log your weight to track progress over time',
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Log Weight'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF6C5CE7),
          ),
        ),
      ],
    );
  }
}
