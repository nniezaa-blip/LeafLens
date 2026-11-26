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
          const SizedBox(height: AppSpacing.s6),
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
      fill: AppColors.transparent,
      shape: AppShape.all(AppRadii.sm),
      onPressed: onTap,
      childFills: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s4,
          vertical: AppSpacing.s10,
        ),
        child: Row(
          children: [
            GlyphIcon(
              _iconOf(sensorKey),
              size: AppSizes.iconLg,
              color: scheme.primary,
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _labelOf(sensorKey),
                    style: DashboardText.title(context),
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  _EnvironmentStatus(
                    sensorKey: sensorKey,
                    reading: reading,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            _ReadingValue(reading: reading),
            const SizedBox(width: AppSpacing.s6),
            GlyphIcon(
              AppGlyphs.chevronForward,
              size: AppSizes.iconSm,
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
}

class _EnvironmentStatus extends StatelessWidget {
  const _EnvironmentStatus({
    required this.sensorKey,
    required this.reading,
  });

  final SensorKey sensorKey;
  final SensorReading? reading;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final reading = this.reading;
    if (reading == null) {
      return Text('No reading', style: DashboardText.label(context));
    }
    if (reading.isStale) {
      return Row(
        children: [
          Container(
            width: AppSizes.dot,
            height: AppSizes.dot,
            decoration: BoxDecoration(
              color: scheme.warning,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.s6),
          Expanded(
            child: Text(
              'Last known · ${reading.ageLabel}',
              style: AppTextStyle.caption1
                  .of(context, emphasized: true)
                  .copyWith(color: scheme.warning),
            ),
          ),
        ],
      );
    }
    final status = _statusOf(reading.value);
    final color = switch (status.tone) {
      DashboardChipTone.ok => scheme.success,
      DashboardChipTone.warn => scheme.warning,
      DashboardChipTone.danger => scheme.error,
      DashboardChipTone.idle => scheme.onSurfaceVariant,
    };
    return Row(
      children: [
        Container(
          width: AppSizes.dot,
          height: AppSizes.dot,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.s6),
        Expanded(
          child: Text(
            status.label,
            style: AppTextStyle.caption1
                .of(context, emphasized: true)
                .copyWith(color: color),
          ),
        ),
      ],
    );
  }

  ({String label, DashboardChipTone tone}) _statusOf(double value) {
    return switch (sensorKey) {
      SensorKey.temperature => _temperatureStatus(value),
      SensorKey.humidity => _humidityStatus(value),
      SensorKey.soilMoisture => _soilStatus(value),
      SensorKey.waterLevel => (
        label: 'Recorded',
        tone: DashboardChipTone.idle,
      ),
    };
  }

  ({String label, DashboardChipTone tone}) _temperatureStatus(double value) {
    if (value < 10 || value > 35) {
      return (label: 'Out of range', tone: DashboardChipTone.danger);
    }
    if (value < 15) return (label: 'Cool', tone: DashboardChipTone.warn);
    if (value > 30) return (label: 'Warm', tone: DashboardChipTone.warn);
    return (label: 'Optimal', tone: DashboardChipTone.ok);
  }

  ({String label, DashboardChipTone tone}) _humidityStatus(double value) {
    if (value < 30 || value > 80) {
      return (label: 'Out of range', tone: DashboardChipTone.danger);
    }
    if (value < 40) return (label: 'Low', tone: DashboardChipTone.warn);
    if (value > 70) return (label: 'High', tone: DashboardChipTone.warn);
    return (label: 'Optimal', tone: DashboardChipTone.ok);
  }

  ({String label, DashboardChipTone tone}) _soilStatus(double value) {
    if (value < 20) return (label: 'Dry', tone: DashboardChipTone.danger);
    if (value < 35) return (label: 'Low', tone: DashboardChipTone.warn);
    if (value > 80) return (label: 'Wet', tone: DashboardChipTone.warn);
    return (label: 'Optimal', tone: DashboardChipTone.ok);
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
      height: AppSizes.line,
      color: context.colorScheme.outlineVariant.withValues(
        alpha: AppOpacity.soft,
      ),
    );
  }
}
