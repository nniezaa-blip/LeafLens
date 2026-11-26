import 'package:lextari/ui/ui.dart';
import 'package:lextari/widgets/app_text_field.dart';

/// Second onboarding step: name the device and give its FavorIoT ID.
class DeviceDetailsStep extends StatelessWidget {
  /// Creates a [DeviceDetailsStep].
  const DeviceDetailsStep({
    required this.formKey,
    required this.nameController,
    required this.deviceIdController,
    required this.enabled,
    super.key,
  });

  /// Form key used by the connect action.
  final GlobalKey<FormState> formKey;

  /// Device display-name controller.
  final TextEditingController nameController;

  /// FavorIoT developer-ID controller.
  final TextEditingController deviceIdController;

  /// Whether the fields accept input.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: nameController,
            label: 'Device name',
            hint: 'My Lextari',
            enabled: enabled,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Device name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.s12),
          AppTextField(
            controller: deviceIdController,
            label: 'FavorIoT developer ID',
            hint: 'Agrilink_1_device@username',
            enabled: enabled,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Device developer ID is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
