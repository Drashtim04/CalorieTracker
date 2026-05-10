import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../providers/dashboard_providers.dart';

/// Three-segment donut showing macro calorie contribution shares.
class MacroDonutChart extends StatefulWidget {
  const MacroDonutChart({super.key, required this.data, this.size = 100});

  final DashboardData data;
  final double size;

  @override
  State<MacroDonutChart> createState() => _MacroDonutChartState();
}

class _MacroDonutChartState extends State<MacroDonutChart>
    with SingleTickerProviderStateMixin {
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
  void didUpdateWidget(MacroDonutChart old) {
    super.didUpdateWidget(old);
    if (old.data.consumed != widget.data.consumed) {
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
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final d = widget.data;
    final isEmpty = d.consumed == 0;

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _DonutPainter(
            proteinShare: isEmpty ? 0 : d.proteinShare * _anim.value,
            carbsShare: isEmpty ? 0 : d.carbsShare * _anim.value,
            fatsShare: isEmpty ? 0 : d.fatsShare * _anim.value,
            isEmpty: isEmpty,
            emptyColor: cs.surfaceContainerHighest,
            strokeWidth: 14,
          ),
          child: Center(
            child: isEmpty
                ? Icon(Icons.donut_large_rounded,
                    color: cs.outlineVariant, size: 28)
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${d.proteinKcal.toStringAsFixed(0)}',
                        style: tt.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF4CAF82),
                          fontSize: 9,
                        ),
                      ),
                      Text(
                        'P·C·F',
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({
    required this.proteinShare,
    required this.carbsShare,
    required this.fatsShare,
    required this.isEmpty,
    required this.emptyColor,
    required this.strokeWidth,
  });

  final double proteinShare;
  final double carbsShare;
  final double fatsShare;
  final bool isEmpty;
  final Color emptyColor;
  final double strokeWidth;

  static const _protein = Color(0xFF4CAF82);
  static const _carbs = Color(0xFFF7B731);
  static const _fats = Color(0xFFE17055);
  static const _gap = 0.04; // radians gap between segments

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    if (isEmpty) {
      canvas.drawArc(
        rect,
        0,
        2 * math.pi,
        false,
        Paint()
          ..color = emptyColor
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
      return;
    }

    // Draw three segments
    _drawSegment(canvas, rect, -math.pi / 2, proteinShare, _protein);
    _drawSegment(canvas, rect, -math.pi / 2 + proteinShare * 2 * math.pi + _gap,
        carbsShare, _carbs);
    _drawSegment(
      canvas,
      rect,
      -math.pi / 2 +
          (proteinShare + carbsShare) * 2 * math.pi +
          2 * _gap,
      fatsShare,
      _fats,
    );
  }

  void _drawSegment(
      Canvas canvas, Rect rect, double start, double share, Color color) {
    if (share <= 0) return;
    final sweep = share * 2 * math.pi - _gap;
    if (sweep <= 0) return;
    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.proteinShare != proteinShare ||
      old.carbsShare != carbsShare ||
      old.fatsShare != fatsShare;
}
