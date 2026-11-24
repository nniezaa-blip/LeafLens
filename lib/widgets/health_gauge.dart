import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:lextari/features/dashboard/domain/growth_health_score.dart';

/// Circular gauges that shows the health score with color-coded arc.
///
/// Green (optimal) → yellow (caution) → red (critical).
/// Transitions the arc color smoothly as score drops.
class HealthGauge extends StatelessWidget {
  /// Creates a [HealthGauge] displaying the given [result].
  const HealthGauge({
    required this.result,
    super.key,
    this.size = 200,
  });

  /// The computed health score result to display.
  final HealthScoreResult result;

  /// The diameter of the gauge in logical pixels.
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(context, result.status);
    final bgColor = color.withValues(alpha: 0.15);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              score: result.score / 100,
              color: color,
              bgColor: bgColor,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${result.score.round()}%',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                _label(result.status),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _label(HealthStatus status) => switch (status) {
    HealthStatus.optimal => 'Optimal',
    HealthStatus.moderate => 'Moderate',
    HealthStatus.caution => 'Caution',
    HealthStatus.danger => 'Danger',
    HealthStatus.critical => 'Critical',
  };

  Color _statusColor(BuildContext context, HealthStatus status) =>
      switch (status) {
        HealthStatus.optimal => const Color(0xFF4CAF50),
        HealthStatus.moderate => const Color(0xFF8BC34A),
        HealthStatus.caution => const Color(0xFFFFC107),
        HealthStatus.danger => const Color(0xFFFF9800),
        HealthStatus.critical => Theme.of(context).colorScheme.error,
      };
}

/// Custom painter that draws the gauge ring arc.
class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.score,
    required this.color,
    required this.bgColor,
  });
  final double score;
  final Color color;
  final Color bgColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * score;

    // Background ring
    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Score arc
    if (score > 0) {
      final arcPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.score != score;
}
