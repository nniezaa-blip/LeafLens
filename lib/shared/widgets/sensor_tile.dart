import 'package:flutter/material.dart';

import 'package:lextari/features/dashboard/domain/sensor_key.dart';
import 'package:lextari/features/dashboard/domain/sensor_reading.dart';

/// Displays a single sensor value with label, unit, and stale indicator.
///
/// If [reading] is null, shows a skeleton placeholder.
/// If reading is stale, shows a warning icon + age label in error color.
class SensorTile extends StatelessWidget {
  /// Creates a [SensorTile] for the given [sensor] with an optional [reading].
  const SensorTile({required this.sensor, super.key, this.reading});

  /// The type of sensor this tile represents (e.g. temperature, humidity).
  final SensorKey sensor;

  /// The current reading, or null to show a skeleton placeholder.
  final SensorReading? reading;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme;

    if (reading == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 12,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 80,
                height: 28,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(sensor.name, style: textStyle.labelMedium),
                if (reading!.isStale) ...[
                  const SizedBox(width: 4),
                  Tooltip(
                    message: 'Last updated ${reading!.ageLabel}',
                    child: Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: cs.error,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${reading!.value.toStringAsFixed(1)}${sensor.unit}',
              style: textStyle.headlineLarge?.copyWith(
                color: reading!.isStale ? cs.error : cs.onSurface,
              ),
            ),
            Text(
              reading!.ageLabel,
              style: textStyle.bodySmall?.copyWith(
                color: reading!.isStale ? cs.error : cs.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
