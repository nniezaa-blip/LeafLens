import 'package:lextari/features/dashboard/domain/sensor_key.dart';
import 'package:lextari/features/dashboard/domain/sensor_reading.dart';
import 'package:lextari/features/dashboard/presentation/widgets/dashboard_card.dart';
import 'package:lextari/features/stats/presentation/trend_metric.dart';
import 'package:lextari/ui/ui.dart';

/// The environment sensor card: temperature, humidity and soil moisture.
class EnvironmentCard extends StatelessWidget {
  /// Creates an [EnvironmentCard].
  const EnvironmentCard({
    required this.telemetry,
    required this.onOpenTrend,
    super.key,
  });

  /// Latest readings keyed by sensor.
  final Map<SensorKey, SensorReading> telemetry;

  /// Opens the trend screen for a metric.
  final ValueChanged<TrendMetric> onOpenTrend;

  static const List<SensorKey> _sensors = [
    SensorKey.temperature,
    SensorKey.humidity,
    SensorKey.soilMoisture,
  ];

  @override
  Widget build(BuildContext context) {
    final readings = [for (final key in _sensors) telemetry[key]];
    final missing = readings.every((reading) => reading == null);
    final stale = readings.any((reading) => reading?.isStale ?? false);
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashboardCardHeader(
            glyph: AppGlyphs.grass,
            title: 'Environment',
            trailing: [
              DashboardChip(
                label: missing
                    ? 'No data'
                    : stale
                    ? 'Last known'
                    : 'Live',
                tone: missing
                    ? DashboardChipTone.idle
                    : stale
                    ? DashboardChipTone.warn
                    : DashboardChipTone.ok,
                dot: !missing,
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (var index = 0; index < _sensors.length; index++) ...[
            if (index > 0) const _RowDivider(),
            _EnvironmentRow(
              sensorKey: _sensors[index],
              reading: telemetry[_sensors[index]],
              onTap: () => onOpenTrend(_metricOf(_sensors[index])),
            ),
          ],
        ],
      ),
    );
  }

  TrendMetric _metricOf(SensorKey key) => switch (key) {
    SensorKey.temperature => TrendMetric.temperature,
    SensorKey.humidity => TrendMetric.humidity,
    _ => TrendMetric.moisture,
  };
}

class _EnvironmentRow extends StatelessWidget {
  const _EnvironmentRow({
    required this.sensorKey,
    required this.reading,
    required this.onTap,
  });

  final SensorKey sensorKey;
  final SensorReading? reading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return PressSurface(
      fill: const Color(0x00000000),
      shape: AppShape.all(AppRadii.sm),
      onPressed: onTap,
      childFills: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Row(
          children: [
            GlyphIcon(_iconOf(sensorKey), size: 20, color: scheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _labelOf(sensorKey),
                    style: DashboardText.title(context),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _statusOf(reading),
                    style: DashboardText.label(context),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _ReadingValue(reading: reading),
            const SizedBox(width: 6),
            GlyphIcon(
              AppGlyphs.chevronForward,
              size: 16,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Glyph _iconOf(SensorKey key) => switch (key) {
    SensorKey.temperature => AppGlyphs.thermostat,
    SensorKey.humidity => AppGlyphs.waterDrop,
    SensorKey.soilMoisture => AppGlyphs.grass,
    SensorKey.waterLevel => AppGlyphs.waterTank,
  };

  String _labelOf(SensorKey key) => switch (key) {
    SensorKey.temperature => 'Temperature',
    SensorKey.humidity => 'Humidity',
    SensorKey.soilMoisture => 'Soil Moisture',
    SensorKey.waterLevel => 'Water Level',
  };

  String _statusOf(SensorReading? reading) {
    if (reading == null) return 'No reading';
    if (reading.isStale) return 'Last known ${reading.ageLabel}';
    return 'Updated ${reading.ageLabel}';
  }
}

class _ReadingValue extends StatelessWidget {
  const _ReadingValue({required this.reading});

  final SensorReading? reading;

  @override
  Widget build(BuildContext context) {
    final reading = this.reading;
    if (reading == null) {
      return Text(
        '--',
        style: DashboardText.figure(context).copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      );
    }
    final value = reading.value == reading.value.roundToDouble()
        ? reading.value.toStringAsFixed(0)
        : reading.value.toStringAsFixed(1);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: value, style: DashboardText.figure(context)),
          TextSpan(
            text: ' ${reading.unit}',
            style: DashboardText.unit(context),
          ),
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: context.colorScheme.outlineVariant.withValues(alpha: 0.4),
    );
  }
}
