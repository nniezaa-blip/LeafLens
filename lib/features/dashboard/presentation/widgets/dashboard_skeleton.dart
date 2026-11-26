import 'package:lextari/features/dashboard/presentation/widgets/dashboard_card.dart';
import 'package:lextari/ui/ui.dart';

/// The dashboard's first-load placeholder, shaped like the real cards.
class DashboardSkeleton extends StatelessWidget {
  /// Creates a [DashboardSkeleton].
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HealthSkeleton(),
        const SizedBox(height: AppSpacing.s16),
        _ControlsSkeleton(),
        const SizedBox(height: AppSpacing.s16),
        _EnvironmentSkeleton(),
        const SizedBox(height: AppSpacing.s16),
        _WaterSkeleton(),
      ],
    );
  }
}

class _HealthSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SkeletonHeader(width: AppSkeleton.healthHeaderWidth),
          SizedBox(height: AppSpacing.s16),
          Row(
            children: [
              SkeletonPill(
                width: AppSkeleton.healthGauge,
                height: AppSkeleton.healthGauge,
              ),
              SizedBox(width: AppSpacing.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonPill(
                      width: double.infinity,
                      height: AppSkeleton.line,
                    ),
                    SizedBox(height: AppSpacing.s8),
                    SkeletonPill(
                      width: AppSkeleton.healthLineWidth,
                      height: AppSkeleton.line,
                    ),
                    SizedBox(height: AppSpacing.s12),
                    SkeletonPill(
                      width: AppSkeleton.healthSubWidth,
                      height: AppSkeleton.subline,
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
}

class _ControlsSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SkeletonHeader(width: AppSkeleton.shortLine),
          const SizedBox(height: AppSpacing.s14),
          Row(
            children: [
              for (var index = 0; index < 3; index++) ...[
                if (index > 0) const SizedBox(width: AppSpacing.s8),
                const Expanded(
                  child: SkeletonPill(
                    width: AppSkeleton.controlTileWidth,
                    height: AppSkeleton.tileHeight,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _EnvironmentSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SkeletonHeader(width: AppSkeleton.mediumLine),
          const SizedBox(height: AppSpacing.s10),
          for (var index = 0; index < 3; index++) ...[
            if (index > 0) const SizedBox(height: AppSpacing.s18),
            const Row(
              children: [
                SkeletonPill(
                  width: AppSkeleton.environmentIcon,
                  height: AppSkeleton.environmentIcon,
                ),
                SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonPill(
                        width: AppSkeleton.environmentLabelWidth,
                        height: AppSkeleton.environmentLabelHeight,
                      ),
                      SizedBox(height: AppSpacing.s6),
                      SkeletonPill(
                        width: AppSkeleton.environmentSubWidth,
                        height: AppSkeleton.environmentSubHeight,
                      ),
                    ],
                  ),
                ),
                SkeletonPill(
                  width: AppSkeleton.environmentValueWidth,
                  height: AppSkeleton.environmentValueHeight,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _WaterSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SkeletonHeader(width: AppSkeleton.waterHeaderWidth),
          SizedBox(height: AppSpacing.s14),
          Row(
            children: [
              SkeletonPill(
                width: AppSkeleton.tankWidth,
                height: AppSkeleton.tankHeight,
              ),
              SizedBox(width: AppSpacing.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonPill(
                      width: AppSkeleton.waterLabelWidth,
                      height: AppSkeleton.waterLabelHeight,
                    ),
                    SizedBox(height: AppSpacing.s8),
                    SkeletonPill(
                      width: AppSkeleton.waterFigureWidth,
                      height: AppSkeleton.waterFigureHeight,
                    ),
                    SizedBox(height: AppSpacing.s10),
                    SkeletonPill(
                      width: AppSkeleton.waterCaptionWidth,
                      height: AppSkeleton.waterCaptionHeight,
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
}

class _SkeletonHeader extends StatelessWidget {
  const _SkeletonHeader({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SkeletonPill(
          width: AppSkeleton.headerIcon,
          height: AppSkeleton.headerIcon,
        ),
        const SizedBox(width: AppSpacing.s8),
        SkeletonPill(width: width, height: AppSkeleton.headerTitle),
        const Spacer(),
        const SkeletonPill(
          width: AppSkeleton.headerChipWidth,
          height: AppSkeleton.headerChipHeight,
        ),
      ],
    );
  }
}
