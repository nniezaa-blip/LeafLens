import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lextari/features/dashboard/presentation/widgets/health_score_card.dart';
import 'package:lextari/ui/ui.dart';

void main() {
  runApp(const ProviderScope(child: _HealthStatesPreview()));
}

class _HealthStatesPreview extends StatelessWidget {
  const _HealthStatesPreview();

  @override
  Widget build(BuildContext context) {
    return PrismApp(
      title: 'Health card states',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.prismLight(),
      builder: (context, child) {
        final size = MediaQuery.sizeOf(context);
        return ViewScope(
          size: size,
          isMobile: size.width < 600,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: Scaffold(
        title: 'Health card states',
        body: Padding(
          padding: EdgeInsets.only(top: context.contentTopPadding),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: 390,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const HealthScoreCard(
                      score: 86,
                      statusText:
                          'Conditions are stable. Keep the current schedule.',
                      gaugeColor: AppColors.success,
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    const HealthScoreCard(
                      score: 70,
                      statusText:
                          'Conditions are mostly stable. Watch the soil moisture.',
                      gaugeColor: AppColors.success,
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    const HealthScoreCard(
                      score: 55,
                      statusText:
                          'The plant needs attention. Check soil and water.',
                      gaugeColor: AppColors.warning,
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    const HealthScoreCard(
                      score: 40,
                      statusText:
                          'The plant is stressed. Adjust watering and check the sensors.',
                      gaugeColor: AppColors.danger,
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    const HealthScoreCard(
                      score: 22,
                      statusText:
                          'Immediate action needed. Check the tank and soil sensor.',
                      gaugeColor: AppColors.danger,
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    const HealthScoreCard(
                      score: 40,
                      statusText:
                          'The plant is stressed. Adjust watering and check the sensors.',
                      gaugeColor: AppColors.danger,
                      warningText: 'SAFETY LOCKOUT',
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    HealthScoreCard(
                      score: 55,
                      statusText: 'Soil is dry. Water the plant.',
                      gaugeColor: AppColors.warning,
                      actionLabel: 'Water now',
                      onAction: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
