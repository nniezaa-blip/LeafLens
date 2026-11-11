import 'package:flutter/material.dart';

import 'package:lextari/core/theme/app_colors.dart';
import 'package:lextari/features/dashboard/presentation/widgets/mini_gauge.dart';

/// Sensor reading card displayed on the dashboard.
///
/// Shows a [MiniGauge] on the left, the sensor name and unit on the
/// top-right, a unit icon in the top-right corner, a status message, and a
/// "More" link at the bottom-right.
class SensorCard extends StatelessWidget {
  /// Creates a [SensorCard].
  const SensorCard({
    required this.sensorName,
    required this.value,
    required this.unit,
    required this.unitIcon,
    required this.statusText,
    required this.gaugeColor,
    super.key,
    this.onMoreTap,
    this.isStale = false,
  });

  /// Display name (e.g. "Temperature", "Humidity").
  final String sensorName;

  /// Numeric value to display.
  final double value;

  /// Unit string (e.g. "°C", "%").
  final String unit;

  /// Icon representing the unit (e.g. thermometer, water droplet).
  final IconData unitIcon;

  /// Status description (e.g. "Temperature is normal", "Saturated").
  final String statusText;

  /// Colour of the gauge arc.
  final Color gaugeColor;

  /// Called when the user taps "More". When null, the link is hidden.
  final VoidCallback? onMoreTap;

  /// Whether the reading is stale.
  final bool isStale;

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
          _GaugeSection(value: value, gaugeColor: gaugeColor),
          _InfoSection(
            sensorName: sensorName,
            statusText: statusText,
            statusColor: gaugeColor,
          ),
          _UnitBadge(icon: unitIcon, unit: unit),
          if (onMoreTap != null) _MoreLink(onTap: onMoreTap!),
        ],
      ),
    );
  }
}

//
// Private widgets
//

class _GaugeSection extends StatelessWidget {
  const _GaugeSection({required this.value, required this.gaugeColor});

  final double value;
  final Color gaugeColor;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 8,
      top: 0,
      bottom: 0,
      child: Center(
        child: MiniGauge(
          value: value / 100,
          color: gaugeColor,
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.sensorName,
    required this.statusText,
    required this.statusColor,
  });

  final String sensorName;
  final String statusText;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 168,
      right: 44,
      top: 20,
      bottom: 20,
      child: Stack(
        children: [
          _SensorTitle(name: sensorName),
          Align(
            alignment: Alignment.centerLeft,
            child: _StatusText(text: statusText, color: statusColor),
          ),
        ],
      ),
    );
  }
}

class _SensorTitle extends StatelessWidget {
  const _SensorTitle({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: AppColors.offBlack,
      ),
    );
  }
}

class _UnitBadge extends StatelessWidget {
  const _UnitBadge({required this.icon, required this.unit});

  final IconData icon;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      right: 16,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: AppColors.offBlack),
          const SizedBox(width: 4),
          Text(
            unit,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: AppColors.offBlack,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusText extends StatelessWidget {
  const _StatusText({required this.text, required this.color});

  final String text;
  final Color color;

  /// Returns [color] with boosted saturation, full opacity, and a slightly
  /// darker tone so the status line stays legible against the card background.
  Color get _readableColor {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withSaturation((hsl.saturation + 0.25).clamp(0.0, 1.0))
        .withLightness((hsl.lightness * 0.7).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
        fontSize: 16,
        color: _readableColor,
      ),
    );
  }
}

class _MoreLink extends StatelessWidget {
  const _MoreLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'More',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: AppColors.offBlack,
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.double_arrow,
              size: 20,
              color: AppColors.offBlack,
            ),
          ],
        ),
      ),
    );
  }
}
