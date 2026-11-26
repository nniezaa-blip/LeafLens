import 'package:lextari/ui/ui.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    this.controller,
    this.hint,
    this.label,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    super.key,
  });

  final TextEditingController? controller;
  final String? hint;
  final String? label;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      decoration: InputDecoration(
        hintText: hint ?? label,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
    final fieldLabel = label;
    if (fieldLabel == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          fieldLabel,
          style: AppTextStyle.caption1
              .of(context, emphasized: true)
              .copyWith(color: context.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.s6),
        field,
      ],
    );
  }
}
