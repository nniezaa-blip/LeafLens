import 'dart:math' as math;

import 'package:lextari/features/dashboard/presentation/widgets/mini_gauge.dart';
import 'package:lextari/ui/ui.dart';

/// Sensor reading card displayed on the dashboard.
///
/// The gauge takes a share of the card's width and the reading column takes
/// the rest, so the card grows from its content on any screen.
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
  final Glyph unitIcon;

  /// Status description (e.g. "Temperature is normal", "Saturated").
  final String statusText;

  /// Colour of the gauge arc.
  final Color gaugeColor;

  /// Called when the user taps "More". When null, the link is hidden.
  final VoidCallback? onMoreTap;

  /// Whether the reading is stale.
  final bool isStale;

  /// The gauge takes this share of the card's inner width.
  static const double _gaugeWidthShare = 0.38;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gaugeSize = math.min(
            AppSizes.gaugeDefault,
            constraints.maxWidth * _gaugeWidthShare,
          );
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MiniGauge(
                value: (value / 100).clamp(0.0, 1.0),
                color: gaugeColor,
                size: gaugeSize,
              ),
              const SizedBox(width: AppSpacing.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CardHeader(
                      sensorName: sensorName,
                      unitIcon: unitIcon,
                      unit: unit,
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Text(
                      statusText,
                      style: AppTextStyle.callout
                          .of(context, emphasized: true)
                          .copyWith(
                            color: isStale ? AppColors.redAlert : gaugeColor,
                          ),
                    ),
                    if (onMoreTap != null) ...[
                      const SizedBox(height: AppSpacing.s12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _MoreLink(onTap: onMoreTap!),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s4),
              GlyphIcon(
                AppGlyphs.chevronForward,
                size: AppSizes.iconSm,
                color: scheme.onSurfaceVariant,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.sensorName,
    required this.unitIcon,
    required this.unit,
  });

  final String sensorName;
  final Glyph unitIcon;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            sensorName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.title3
                .of(context, emphasized: true)
                .copyWith(color: scheme.onSurface),
          ),
        ),
        GlyphIcon(unitIcon, size: AppSizes.iconAction, color: scheme.onSurface),
        const SizedBox(width: AppSpacing.s4),
        Text(
          unit,
          style: AppTextStyle.title3
              .of(context, emphasized: true)
              .copyWith(color: scheme.onSurface),
        ),
      ],
    );
  }
}

class _MoreLink extends StatelessWidget {
  const _MoreLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'More',
            style: AppTextStyle.subheadline
                .of(context, emphasized: true)
                .copyWith(color: context.colorScheme.onSurface),
          ),
          const SizedBox(width: AppSpacing.s4),
          GlyphIcon(
            AppGlyphs.doubleArrow,
            size: AppSizes.iconLg,
            color: context.colorScheme.onSurface,
          ),
        ],
      ),
    );
  }
}
