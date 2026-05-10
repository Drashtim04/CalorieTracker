import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A large animated circular progress ring for the dashboard hero section.
///
/// Animates from 0 → [progress] on first build and whenever values change.
class DashboardCalorieRing extends StatefulWidget {
  const DashboardCalorieRing({
    super.key,
    required this.consumed,
    required this.goal,
    required this.ringSize,
    this.strokeWidth = 16,
  });

  final double consumed;
  final double goal;
  final double ringSize;
  final double strokeWidth;

  @override
  State<DashboardCalorieRing> createState() => _DashboardCalorieRingState();
}

class _DashboardCalorieRingState extends State<DashboardCalorieRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  late double _targetProgress;

  @override
  void initState() {
    super.initState();
    _targetProgress = _clampedProgress;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(DashboardCalorieRing old) {
    super.didUpdateWidget(old);
    if (old.consumed != widget.consumed || old.goal != widget.goal) {
      _targetProgress = _clampedProgress;
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

  double get _clampedProgress =>
      widget.goal > 0 ? (widget.consumed / widget.goal).clamp(0.0, 1.0) : 0.0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isOver = widget.consumed > widget.goal && widget.goal > 0;
    final remaining =
        (widget.goal - widget.consumed).clamp(0.0, double.infinity);
    final pct =
        widget.goal > 0 ? (widget.consumed / widget.goal * 100).clamp(0, 999) : 0;

    final ringColor = isOver ? cs.error : cs.primary;
    final glowColor = (isOver ? cs.error : cs.primary).withOpacity(0.25);

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final animatedProgress = _targetProgress * _anim.value;
        return SizedBox(
          width: widget.ringSize,
          height: widget.ringSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glow shadow
              Container(
                width: widget.ringSize * 0.82,
                height: widget.ringSize * 0.82,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: glowColor,
                      blurRadius: 32,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),

              // Ring painter
              CustomPaint(
                size: Size(widget.ringSize, widget.ringSize),
                painter: _MultiRingPainter(
                  progress: animatedProgress,
                  trackColor: cs.surfaceContainerHighest,
                  fillColor: ringColor,
                  strokeWidth: widget.strokeWidth,
                ),
              ),

              // Center content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.consumed.toStringAsFixed(0),
                    style: tt.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: isOver ? cs.error : cs.onSurface,
                      height: 1,
                    ),
                  ),
                  Text(
                    'kcal eaten',
                    style: tt.bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: isOver
                          ? cs.errorContainer
                          : cs.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isOver
                          ? '${(widget.consumed - widget.goal).toStringAsFixed(0)} over'
                          : '${remaining.toStringAsFixed(0)} left',
                      style: tt.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isOver
                            ? cs.onErrorContainer
                            : cs.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${pct.toStringAsFixed(0)}% of goal',
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MultiRingPainter extends CustomPainter {
  const _MultiRingPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color trackColor;
  final Color fillColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track
    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = trackColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Fill arc
    if (progress > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = fillColor
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_MultiRingPainter old) =>
      old.progress != progress || old.fillColor != fillColor;
}
