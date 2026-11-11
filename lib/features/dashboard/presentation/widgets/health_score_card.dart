import 'package:flutter/material.dart';

import 'package:lextari/core/theme/app_colors.dart';
import 'package:lextari/features/dashboard/presentation/widgets/mini_gauge.dart';

/// Overall health score card displayed at the bottom of the sensor list.
///
/// Shows the GHS gauge, a combined status message, and an optional
/// warning line when the plant needs immediate attention.
class HealthScoreCard extends StatelessWidget {
  /// Creates a [HealthScoreCard].
  const HealthScoreCard({
    required this.score,
    required this.statusText,
    required this.gaugeColor,
    super.key,
    this.warningText,
  });

  /// GHS score as a percentage (0–100).
  final double score;

  /// Combined status description.
  final String statusText;

  /// Colour of the gauge arc.
  final Color gaugeColor;

  /// Optional warning line shown below the status (e.g. "STOP WATERING!").
  final String? warningText;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 191,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: MiniGauge(
                value: score / 100,
                color: gaugeColor,
              ),
            ),
          ),
          _InfoSection(
            statusText: statusText,
            gaugeColor: gaugeColor,
            warningText: warningText,
          ),
        ],
      ),
    );
  }
}

//
// Private widgets
//

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.statusText,
    required this.gaugeColor,
    this.warningText,
  });

  final String statusText;
  final Color gaugeColor;
  final String? warningText;

  /// Returns [gaugeColor] with boosted saturation, full opacity, and a
  /// slightly darker tone so the warning line stays legible against the card.
  Color get _warningColor {
    final hsl = HSLColor.fromColor(gaugeColor);
    return hsl
        .withSaturation((hsl.saturation + 0.25).clamp(0.0, 1.0))
        .withLightness((hsl.lightness * 0.7).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 168,
      right: 16,
      top: 20,
      bottom: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Health Score',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              fontSize: 20,
              color: AppColors.offBlack,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            statusText,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              fontSize: 16,
              color: AppColors.darkGrey,
            ),
          ),
          if (warningText != null) ...[
            const SizedBox(height: 8),
            Text(
              warningText!,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                fontSize: 16,
                color: _warningColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
