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
          _SkeletonHeader(width: 110),
          SizedBox(height: AppSpacing.s16),
          Row(
            children: [
              SkeletonPill(width: 108, height: 108),
              SizedBox(width: AppSpacing.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonPill(width: double.infinity, height: 18),
                    SizedBox(height: AppSpacing.s8),
                    SkeletonPill(width: 180, height: 18),
                    SizedBox(height: AppSpacing.s12),
                    SkeletonPill(width: 150, height: 12),
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
                const Expanded(child: SkeletonPill(width: 96, height: 84)),
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
                SkeletonPill(width: 22, height: 22),
                SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonPill(width: 110, height: 15),
                      SizedBox(height: AppSpacing.s6),
                      SkeletonPill(width: 64, height: 11),
                    ],
                  ),
                ),
                SkeletonPill(width: 64, height: 26),
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
          _SkeletonHeader(width: 120),
          SizedBox(height: AppSpacing.s14),
          Row(
            children: [
              SkeletonPill(width: 58, height: 96),
              SizedBox(width: AppSpacing.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonPill(width: 90, height: 13),
                    SizedBox(height: AppSpacing.s8),
                    SkeletonPill(width: 70, height: 26),
                    SizedBox(height: AppSpacing.s10),
                    SkeletonPill(width: 130, height: 12),
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
