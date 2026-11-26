import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lextari/core/router/app_routes.dart';
import 'package:lextari/features/dashboard/providers/device_providers.dart';
import 'package:lextari/features/dashboard/providers/telemetry_providers.dart';
import 'package:lextari/features/stats/presentation/trend_metric.dart';
import 'package:lextari/features/stats/presentation/trend_metric_provider.dart';
import 'package:lextari/features/stats/presentation/widgets/trend_chart_card.dart';
import 'package:lextari/features/stats/presentation/widgets/trend_metric_switcher.dart';
import 'package:lextari/ui/ui.dart';

/// Stats / Graphs tab — shows 30-day trends for each sensor metric.
class StatsScreen extends ConsumerWidget {
  /// Creates a [StatsScreen].
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedTrendMetricProvider);
    final hasDevice = ref.watch(hasLinkedDeviceProvider);
    final noDevice = hasDevice.value == false;

    return Scaffold(
      title: 'Stats',
      body: PullToRefresh(
        useGesture: true,
        onRefresh: () => _refresh(ref, selected),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.s20,
            context.contentTopPadding,
            AppSpacing.s20,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Header(),
              const SizedBox(height: AppSpacing.s20),
              if (noDevice)
                Expanded(
                  child: EmptyState(
                    label: 'No device linked',
                    description:
                        'Add a FavorIoT device to start collecting 30-day trends.',
                    action: TextButton(
                      onPressed: () => unawaited(
                        context.push(AppRoutes.onboarding),
                      ),
                      child: const Text('Add device'),
                    ),
                  ),
                )
              else ...[
                TrendMetricSwitcher(
                  selected: selected,
                  onChanged: (metric) => ref
                      .read(selectedTrendMetricProvider.notifier)
                      .select(metric),
                ),
                const SizedBox(height: AppSpacing.s16),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: NavigationDock.insetOf(context) + AppSpacing.s24,
                    ),
                    child: TrendChartCard(metric: selected),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refresh(WidgetRef ref, TrendMetric metric) async {
    final started = DateTime.now();
    ref.invalidate(deviceListProvider);
    if (ref.read(hasLinkedDeviceProvider).value == false) {
      await Future<void>.delayed(AppMotionTokens.minRefreshDuration);
      return;
    }
    ref.invalidate(telemetryHistoryProvider);
    try {
      await ref.read(telemetryHistoryProvider(metric.apiKey).future);
    } on Object {
      // The chart owns its error and empty states.
    }
    final elapsed = DateTime.now().difference(started);
    if (elapsed < AppMotionTokens.minRefreshDuration) {
      await Future<void>.delayed(
        AppMotionTokens.minRefreshDuration - elapsed,
      );
    }
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          headingLevel: 2,
          child: Text(
            '30-Day Trends',
            style: AppTypography.headlineMedium.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(
          'Average readings across the last month',
          style: AppTypography.bodyMedium.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
