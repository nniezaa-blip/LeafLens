import 'dart:math' as math;

import 'package:lextari/features/dashboard/presentation/widgets/dashboard_card.dart';
import 'package:lextari/features/dashboard/presentation/widgets/mini_gauge.dart';
import 'package:lextari/ui/ui.dart';

/// The dashboard's hero card: overall score, status and a short explanation.
///
/// Per-sensor status lives on each environment row, not here.
class HealthScoreCard extends StatelessWidget {
  /// Creates a [HealthScoreCard].
  const HealthScoreCard({
    required this.score,
    required this.statusText,
    required this.gaugeColor,
    super.key,
    this.isStale = false,
    this.hasData = true,
    this.warningText,
    this.actionLabel,
    this.onAction,
  });

  /// GHS score as a percentage (0 to 100).
  final double score;

  /// Informational summary of the overall score.
  final String statusText;

  /// Colour of the gauge arc.
  final Color gaugeColor;

  /// Whether the score comes from readings older than the staleness limit.
  final bool isStale;

  /// Whether every required reading exists for a score.
  final bool hasData;

  /// Optional warning line shown below the score.
  final String? warningText;

  /// Optional action label for the single call to action.
  final String? actionLabel;

  /// Called when the call to action is pressed.
  final VoidCallback? onAction;

  /// The gauge takes this share of the card's inner width.
  static const double _gaugeWidthShare = 0.32;

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
                dot: hasData,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s14),
          LayoutBuilder(
            builder: (context, constraints) {
              final gaugeSize = math.min(
                AppSizes.gauge,
                constraints.maxWidth * _gaugeWidthShare,
              );
              return Row(
                children: [
                  MiniGauge(
                    value: score / 100,
                    color: isStale || !hasData
                        ? scheme.onSurfaceVariant
                        : gaugeColor,
                    size: gaugeSize,
                  ),
                  const SizedBox(width: AppSpacing.s16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          warningText ?? statusText,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.subheadline
                              .of(context, emphasized: true)
                              .copyWith(
                                color: warningText != null
                                    ? scheme.error
                                    : scheme.onSurface,
                              ),
                        ),
                        if (actionLabel != null) ...[
                          const SizedBox(height: AppSpacing.s8),
                          TextButton(
                            onPressed: onAction,
                            child: Text(actionLabel!),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _statusLabel() {
    if (!hasData) return 'No data';
    if (isStale) return 'Last known';
    if (score >= 80) return 'Optimal';
    if (score >= 65) return 'Moderate';
    if (score >= 50) return 'Caution';
    if (score >= 30) return 'Danger';
    return 'Critical';
  }

  DashboardChipTone _scoreTone() {
    if (!hasData) return DashboardChipTone.idle;
    if (isStale) return DashboardChipTone.warn;
    if (score >= 65) return DashboardChipTone.ok;
    if (score >= 50) return DashboardChipTone.warn;
    return DashboardChipTone.danger;
  }
}
