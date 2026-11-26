import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lextari/core/errors/error_handler.dart';
import 'package:lextari/core/errors/failures.dart';
import 'package:lextari/core/router/app_routes.dart';
import 'package:lextari/features/dashboard/providers/device_providers.dart';
import 'package:lextari/features/onboarding/presentation/widgets/device_details_step.dart';
import 'package:lextari/features/onboarding/presentation/widgets/device_type_step.dart';
import 'package:lextari/features/onboarding/presentation/widgets/onboarding_step_indicator.dart';
import 'package:lextari/features/onboarding/providers/onboarding_providers.dart';
import 'package:lextari/ui/ui.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _deviceNameController = TextEditingController();
  final _deviceIdController = TextEditingController();
  bool _isSubmitting = false;
  String _deviceType = 'lextari-env';
  int _step = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _deviceNameController.dispose();
    _deviceIdController.dispose();
    super.dispose();
  }

  void _continue() {
    _pageController.nextPage(
      duration: AppMotionTokens.card,
      curve: AppCurves.settle,
    );
  }

  void _back() {
    _pageController.previousPage(
      duration: AppMotionTokens.card,
      curve: AppCurves.settle,
    );
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(deviceApiProvider)
          .linkDevice(
            platformDeviceId: _deviceIdController.text.trim(),
            deviceName: _deviceNameController.text.trim(),
            deviceType: _deviceType,
          );
      ref.read(deviceProvisioningSkippedProvider.notifier).reset();
      ref.invalidate(deviceListProvider);
    } on Object catch (error) {
      if (!mounted) return;
      ErrorHandler.handle(
        error is Failure ? error : UnknownFailure(error.toString()),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _skip() {
    ref.read(deviceProvisioningSkippedProvider.notifier).skip();
    context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.s24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.s24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _OnboardingHeader(),
                    const SizedBox(height: AppSpacing.s20),
                    OnboardingStepIndicator(
                      currentStep: _step,
                      labels: const ['Device type', 'Details'],
                    ),
                    const SizedBox(height: AppSpacing.s20),
                    SizedBox(
                      height: AppSizes.onboardingPageHeight,
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (index) => setState(() => _step = index),
                        children: [
                          SingleChildScrollView(
                            padding: EdgeInsets.zero,
                            child: DeviceTypeStep(
                              selected: _deviceType,
                              onSelected: (type) =>
                                  setState(() => _deviceType = type),
                            ),
                          ),
                          SingleChildScrollView(
                            padding: EdgeInsets.zero,
                            child: DeviceDetailsStep(
                              formKey: _formKey,
                              nameController: _deviceNameController,
                              deviceIdController: _deviceIdController,
                              enabled: !_isSubmitting,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s24),
                    if (_step == 0)
                      AppButton(
                        label: 'Continue',
                        expand: true,
                        height: AppSizes.onboardingButtonHeight,
                        onPressed: _isSubmitting ? null : _continue,
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: 'Back',
                              variant: AppButtonVariant.outline,
                              expand: true,
                              height: AppSizes.onboardingButtonHeight,
                              onPressed: _isSubmitting ? null : _back,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s8),
                          Expanded(
                            flex: 2,
                            child: AppButton(
                              label: _isSubmitting
                                  ? 'Connecting...'
                                  : 'Connect device',
                              expand: true,
                              height: AppSizes.onboardingButtonHeight,
                              loading: _isSubmitting,
                              onPressed: _isSubmitting ? null : _submit,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: AppSpacing.s4),
                    TextButton(
                      onPressed: _isSubmitting ? null : _skip,
                      child: const Text('Skip for now'),
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

class _OnboardingHeader extends StatelessWidget {
  const _OnboardingHeader();

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Column(
      children: [
        Container(
          width: AppSpacing.s52,
          height: AppSpacing.s52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: scheme.primary.withValues(alpha: AppOpacity.faint),
          ),
          child: GlyphIcon(
            AppGlyphs.device,
            size: AppSizes.iconXxl,
            color: scheme.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        Semantics(
          header: true,
          headingLevel: 1,
          child: Text(
            'Connect your device',
            textAlign: TextAlign.center,
            style: AppTextStyle.title2
                .of(context, emphasized: true)
                .copyWith(color: scheme.onSurface),
          ),
        ),
        const SizedBox(height: AppSpacing.s6),
        Text(
          'Link a FavorIoT device to start monitoring.',
          textAlign: TextAlign.center,
          style: AppTextStyle.subheadline
              .of(context)
              .copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.s12),
        const _BleComingSoonPill(),
      ],
    );
  }
}

class _BleComingSoonPill extends StatelessWidget {
  const _BleComingSoonPill();

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s10,
        vertical: AppSpacing.s4,
      ),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: AppOpacity.whisper),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlyphIcon(
            AppGlyphs.info,
            size: AppSizes.iconXs,
            color: scheme.primary,
          ),
          const SizedBox(width: AppSpacing.s6),
          Flexible(
            child: Text(
              'BLE provisioning coming soon',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: AppTextStyle.caption2
                  .of(context, emphasized: true)
                  .copyWith(color: scheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
