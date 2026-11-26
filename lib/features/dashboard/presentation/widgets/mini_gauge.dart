import 'dart:math' as math;

import 'package:lextari/ui/ui.dart';

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
    this.size = AppSizes.gaugeDefault,
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
              innerColor: context.colorScheme.surface,
            ),
          ),
          Text(
            '${(clamped * 100).round()}%',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: size * AppSizes.gaugeLabelRatio,
              color: context.colorScheme.onSurface,
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
  const _GaugePainter({
    required this.value,
    required this.color,
    required this.innerColor,
  });

  final double value;
  final Color color;
  final Color innerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = AppSizes.gaugeStroke;
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * value;

    // Background circle
    final bgPaint = Paint()
      ..color = color.withValues(alpha: AppOpacity.tint)
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

    // Inner circle
    final innerPaint = Paint()
      ..color = innerColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      center,
      radius - strokeWidth - AppSizes.gaugeInnerGap,
      innerPaint,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.value != value || old.color != color;
}
