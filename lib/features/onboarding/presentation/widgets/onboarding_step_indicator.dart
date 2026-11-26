import 'package:lextari/ui/ui.dart';

/// Two calm segments showing where the onboarding flow is.
class OnboardingStepIndicator extends StatelessWidget {
  /// Creates an [OnboardingStepIndicator].
  const OnboardingStepIndicator({
    required this.currentStep,
    required this.labels,
    super.key,
  });

  /// Zero-based index of the active step.
  final int currentStep;

  /// One label per step.
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var index = 0; index < labels.length; index++) ...[
              if (index > 0) const SizedBox(width: AppSpacing.s6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: AppMotionTokens.control,
                      curve: AppCurves.emphasized,
                      height: AppSpacing.s4,
                      decoration: BoxDecoration(
                        color: index <= currentStep
                            ? scheme.primary
                            : scheme.outlineVariant.withValues(
                                alpha: AppOpacity.soft,
                              ),
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s6),
                    AnimatedDefaultTextStyle(
                      duration: AppMotionTokens.control,
                      curve: AppCurves.emphasized,
                      style: AppTextStyle.caption2
                          .of(context, emphasized: index == currentStep)
                          .copyWith(
                            color: index <= currentStep
                                ? scheme.primary
                                : scheme.onSurfaceVariant,
                          ),
                      child: Text(labels[index]),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
