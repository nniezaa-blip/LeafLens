import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lextari/core/errors/error_handler.dart';
import 'package:lextari/core/errors/failures.dart';
import 'package:lextari/core/router/app_routes.dart';
import 'package:lextari/features/dashboard/providers/device_providers.dart';
import 'package:lextari/ui/ui.dart';
import 'package:lextari/widgets/app_text_field.dart';

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

  @override
  void dispose() {
    _deviceNameController.dispose();
    _deviceIdController.dispose();
    super.dispose();
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
      ref.invalidate(deviceListProvider);
      if (!mounted) return;
      context.go(AppRoutes.dashboard);
    } on Object catch (error) {
      if (!mounted) return;
      ErrorHandler.handle(
        error is Failure ? error : UnknownFailure(error.toString()),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return AppScaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GlyphIcon(
                          AppGlyphs.device,
                          size: 48,
                          color: cs.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Connect your device',
                          style: AppTypography.titleLarge.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Link your existing FavorIoT device to continue. BLE provisioning can be added later when ESP32 hardware is available.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                label: 'Environment',
                                variant: _deviceType == 'lextari-env'
                                    ? AppButtonVariant.primary
                                    : AppButtonVariant.outline,
                                onPressed: _isSubmitting
                                    ? null
                                    : () => setState(
                                        () => _deviceType = 'lextari-env',
                                      ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AppButton(
                                label: 'Water system',
                                variant: _deviceType == 'lextari-water'
                                    ? AppButtonVariant.primary
                                    : AppButtonVariant.outline,
                                onPressed: _isSubmitting
                                    ? null
                                    : () => setState(
                                        () => _deviceType = 'lextari-water',
                                      ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _deviceNameController,
                          label: 'Device name',
                          hint: 'My Lextari',
                          enabled: !_isSubmitting,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Device name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _deviceIdController,
                          label: 'FavorIoT device developer ID',
                          hint: 'Agrilink_1_device@username',
                          enabled: !_isSubmitting,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Device developer ID is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        AppButton(
                          label: _isSubmitting ? 'Linking...' : 'Link device',
                          onPressed: _isSubmitting ? null : _submit,
                          loading: _isSubmitting,
                          expand: true,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No ESP32 yet? Run the virtual device script against FavorIoT, then link the same device ID here.',
                          style: AppTypography.bodySmall.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
