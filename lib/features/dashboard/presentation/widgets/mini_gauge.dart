import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:lextari/core/theme/app_colors.dart';

/// Circular gauge that shows a value as an arc with a white inner circle.
///
/// Used in sensor cards and the health score card on the dashboard.
/// The arc sweeps clockwise from the top, proportional to [value].
class MiniGauge extends StatelessWidget {
  /// Creates a [MiniGauge] with the given [value] (0–1) and [color].
  const MiniGauge({
    required this.value,
    required this.color,
    super.key,
    this.size = 152,
  });

  /// Normalised value between 0.0 and 1.0.
  final double value;

  /// Colour of the arc.
  final Color color;

  /// Diameter of the gauge in logical pixels.
  final double size;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _GaugePainter(
              value: clamped,
              color: color,
            ),
          ),
          Text(
            '${(clamped * 100).round()}%',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: size * 0.24,
              color: AppColors.offBlack,
            ),
          ),
        ],
      ),
    );
  }
}

//
// Private widgets
//

class _GaugePainter extends CustomPainter {
  const _GaugePainter({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 12.0;
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * value;

    // Background circle
    final bgPaint = Paint()
      ..color = AppColors.greyLighter
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Coloured arc
    if (value > 0) {
      final arcPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        arcPaint,
      );
    }

    // White inner circle
    final innerPaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - strokeWidth - 4, innerPaint);
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.value != value || old.color != color;
}
