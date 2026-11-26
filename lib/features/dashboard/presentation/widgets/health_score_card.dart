import 'package:lextari/features/dashboard/presentation/widgets/dashboard_card.dart';
import 'package:lextari/features/dashboard/presentation/widgets/mini_gauge.dart';
import 'package:lextari/ui/ui.dart';
import 'package:lextari/widgets/last_update_time_text.dart';

/// The dashboard's hero card: score, status and the readings that drive it.
class HealthScoreCard extends StatelessWidget {
  /// Creates a [HealthScoreCard].
  const HealthScoreCard({
    required this.score,
    required this.statusText,
    required this.gaugeColor,
    super.key,
    this.warningText,
    this.soilMoisture,
    this.temperature,
    this.humidity,
    this.lastUpdatedAt,
  });

  /// GHS score as a percentage (0 to 100).
  final double score;

  /// Combined status description.
  final String statusText;

  /// Colour of the gauge arc.
  final Color gaugeColor;

  /// Optional warning line shown below the status.
  final String? warningText;

  /// Latest soil moisture reading.
  final double? soilMoisture;

  /// Latest temperature reading.
  final double? temperature;

  /// Latest humidity reading.
  final double? humidity;

  /// When the app last received a telemetry update.
  final DateTime? lastUpdatedAt;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return DashboardCard(
      semanticLabel: 'Health score $statusText',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashboardCardHeader(
            glyph: AppGlyphs.sprout,
            title: 'Health Score',
            trailing: [
              DashboardChip(
                label: _statusLabel(),
                tone: _scoreTone(),
                dot: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              MiniGauge(
                value: score / 100,
                color: gaugeColor,
                size: 112,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.subheadline
                          .of(context, emphasized: true)
                          .copyWith(color: scheme.onSurface),
                    ),
                    if (warningText != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        warningText!,
                        style: AppTextStyle.caption1
                            .of(context, emphasized: true)
                            .copyWith(color: scheme.error),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _driverChip(
                          'Soil',
                          soilMoisture,
                          '%',
                          _moistureTone,
                        ),
                        _driverChip(
                          'Temp',
                          temperature,
                          '°C',
                          _temperatureTone,
                        ),
                        _driverChip(
                          'Humidity',
                          humidity,
                          '%',
                          _humidityTone,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LastUpdateTimeText(
            lastUpdateDate: lastUpdatedAt,
            style: DashboardText.label(context),
          ),
        ],
      ),
    );
  }

  Widget _driverChip(
    String label,
    double? value,
    String unit,
    DashboardChipTone Function(double value) toneOf,
  ) {
    if (value == null) {
      return DashboardChip(label: '$label no reading');
    }
    return DashboardChip(
      label: '$label ${_format(value)}$unit',
      tone: toneOf(value),
    );
  }

  String _format(double value) {
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
  }

  String _statusLabel() {
    if (score >= 80) return 'Optimal';
    if (score >= 65) return 'Moderate';
    if (score >= 50) return 'Caution';
    if (score >= 30) return 'Danger';
    return 'Critical';
  }

  DashboardChipTone _scoreTone() {
    if (score >= 65) return DashboardChipTone.ok;
    if (score >= 50) return DashboardChipTone.warn;
    return DashboardChipTone.danger;
  }

  DashboardChipTone _moistureTone(double value) {
    if (value < 20) return DashboardChipTone.danger;
    if (value < 35 || value > 80) return DashboardChipTone.warn;
    return DashboardChipTone.ok;
  }

  DashboardChipTone _temperatureTone(double value) {
    if (value < 10 || value > 35) return DashboardChipTone.danger;
    if (value < 15 || value > 30) return DashboardChipTone.warn;
    return DashboardChipTone.ok;
  }

  DashboardChipTone _humidityTone(double value) {
    if (value < 30 || value > 80) return DashboardChipTone.danger;
    if (value < 40 || value > 70) return DashboardChipTone.warn;
    return DashboardChipTone.ok;
  }
}
