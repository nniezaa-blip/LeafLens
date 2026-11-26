import 'package:lextari/features/dashboard/presentation/widgets/dashboard_card.dart';
import 'package:lextari/ui/ui.dart';

/// The water tank and refill state card.
class WaterSystemCard extends StatelessWidget {
  /// Creates a [WaterSystemCard].
  const WaterSystemCard({
    required this.waterLevel,
    required this.refillActive,
    required this.safetyLockout,
    super.key,
  });

  /// Latest water level. Values above 100 are shown as raw sensor counts.
  final double? waterLevel;

  /// Whether the refill valve is active.
  final bool refillActive;

  /// Whether the safety cutoff is engaged.
  final bool safetyLockout;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final level = waterLevel;
    final displayLevel = (level ?? 0).clamp(0.0, 100.0);
    final raw = level != null && level > 100;
    final label = level == null
        ? 'No reading'
        : raw
        ? '${_format(level)} raw'
        : '${_format(level)}%';
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashboardCardHeader(
            glyph: AppGlyphs.waterTank,
            title: 'Water system',
            trailing: [
              DashboardChip(
                label: safetyLockout
                    ? 'Safety lockout'
                    : refillActive
                    ? 'Refilling'
                    : 'Idle',
                tone: safetyLockout
                    ? DashboardChipTone.danger
                    : refillActive
                    ? DashboardChipTone.warn
                    : DashboardChipTone.idle,
                dot: refillActive || safetyLockout,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _Tank(level: displayLevel),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Water Level', style: DashboardText.label(context)),
                    const SizedBox(height: 2),
                    Text(label, style: DashboardText.figure(context)),
                    const SizedBox(height: 10),
                    _StateRow(
                      icon: AppGlyphs.refill,
                      label: refillActive ? 'Refill active' : 'Refill idle',
                      color: refillActive
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 6),
                    _StateRow(
                      icon: AppGlyphs.settings,
                      label: safetyLockout
                          ? 'Safety cutoff engaged'
                          : 'Safety cutoff clear',
                      color: safetyLockout
                          ? scheme.error
                          : scheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _format(double value) {
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
  }
}

class _Tank extends StatelessWidget {
  const _Tank({required this.level});

  final double level;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Container(
      width: 58,
      height: 96,
      decoration: ShapeDecoration(
        color: SurfaceLevel.inset.colorOf(scheme),
        shape: AppShape.all(AppRadii.md),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: (level / 100).clamp(0.0, 1.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [scheme.secondary, scheme.primary],
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: GlyphIcon(
              AppGlyphs.waterDrop,
              size: 22,
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _StateRow extends StatelessWidget {
  const _StateRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  final Glyph icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GlyphIcon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: DashboardText.label(context).copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
