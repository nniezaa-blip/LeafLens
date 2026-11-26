import 'package:lextari/features/dashboard/presentation/dashboard_style.dart';
import 'package:lextari/ui/ui.dart';

EdgeInsets dashboardCardPadding(DashboardDensity density) {
  return switch (density) {
    DashboardDensity.standard => const EdgeInsets.symmetric(
      horizontal: 22,
      vertical: 20,
    ),
    DashboardDensity.compact => const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 16,
    ),
    DashboardDensity.mobile => const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 18,
    ),
  };
}

/// A page card with the dashboard's corner radius, padding and shadows.
class DashboardCard extends StatelessWidget {
  /// Creates a [DashboardCard].
  const DashboardCard({
    required this.child,
    this.padding,
    this.onTap,
    this.semanticLabel,
    super.key,
  });

  /// Card content.
  final Widget child;

  /// Inner padding. Defaults to the density's card padding.
  final EdgeInsets? padding;

  /// Optional press action.
  final VoidCallback? onTap;

  /// Screen-reader label for the card.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final density = DashboardDensityScope.of(context);
    final colors = DashboardColors.of(context);
    final shape = AppShape.all(
      density.isDesktop
          ? DashboardCorner.desktopCard
          : DashboardCorner.mobileCard,
    );
    final content = Padding(
      padding: padding ?? dashboardCardPadding(density),
      child: child,
    );
    final card = Container(
      decoration: ShapeDecoration(
        color: colors.card,
        shape: shape,
        shadows: DashboardShadows.e1(context),
      ),
      child: onTap == null
          ? content
          : PressSurface(
              fill: const Color(0x00000000),
              shape: shape,
              onPressed: onTap,
              childFills: true,
              child: content,
            ),
    );
    return Semantics(
      container: true,
      label: semanticLabel,
      child: card,
    );
  }
}

/// The title row shared by dashboard cards.
class DashboardCardHeader extends StatelessWidget {
  /// Creates a [DashboardCardHeader].
  const DashboardCardHeader({
    required this.title,
    this.glyph,
    this.trailing = const <Widget>[],
    super.key,
  });

  /// Card title.
  final String title;

  /// Optional leading glyph.
  final Glyph? glyph;

  /// Widgets placed at the end of the row.
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Row(
      children: [
        if (glyph != null) ...[
          GlyphIcon(glyph!, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DashboardText.title(context),
          ),
        ),
        ...trailing,
      ],
    );
  }
}

/// A compact status pill used in card headers.
enum DashboardChipTone { ok, warn, danger, idle }

/// A small status pill with an optional dot.
class DashboardChip extends StatelessWidget {
  /// Creates a [DashboardChip].
  const DashboardChip({
    required this.label,
    this.tone = DashboardChipTone.idle,
    this.dot = false,
    super.key,
  });

  /// Chip label.
  final String label;

  /// Semantic colour.
  final DashboardChipTone tone;

  /// Shows a leading dot.
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final color = _colorOf(context.colorScheme);
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: color.withValues(alpha: 0.12),
        shape: AppShape.full,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dot) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyle.caption1
                  .of(context, emphasized: true)
                  .copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorOf(ColorScheme scheme) {
    return switch (tone) {
      DashboardChipTone.ok => scheme.success,
      DashboardChipTone.warn => scheme.warning,
      DashboardChipTone.danger => scheme.error,
      DashboardChipTone.idle => scheme.onSurfaceVariant,
    };
  }
}

/// The dashboard's text roles, with tabular figures for readings.
abstract final class DashboardText {
  static TextStyle title(BuildContext context) => AppTextStyle.subheadline
      .of(context, emphasized: true)
      .copyWith(
        color: context.colorScheme.onSurface,
      );

  static TextStyle label(BuildContext context) => AppTextStyle.caption1
      .of(context)
      .copyWith(color: context.colorScheme.onSurfaceVariant);

  static TextStyle figure(BuildContext context) => AppTextStyle.title1
      .of(context, emphasized: true)
      .copyWith(
        color: context.colorScheme.onSurface,
        fontFeatures: const [FontFeature.tabularFigures()],
        letterSpacing: -0.6,
      );

  static TextStyle unit(BuildContext context) => AppTextStyle.subheadline
      .of(context, emphasized: true)
      .copyWith(color: context.colorScheme.onSurfaceVariant);
}
