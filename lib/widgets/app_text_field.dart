import 'package:flutter/material.dart';

/// Consistent text field for Lextari forms.
/// Uses outlined border with floating label.
class AppTextField extends StatelessWidget {
  /// Creates an [AppTextField] with the given [hint] and optional styling.
  const AppTextField({
    super.key,
    this.hint,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
  });

  /// Placeholder text shown inside the input field.
  final String? hint;

  /// Whether to obscure the input (for passwords).
  final bool obscureText;

  /// Controller for reading and manipulating the text value.
  final TextEditingController? controller;

  /// Validator function invoked during form validation.
  final String? Function(String?)? validator;

  /// The type of keyboard to show (email, phone, text, etc.).
  final TextInputType keyboardType;

  /// Optional icon displayed at the start of the input.
  final Widget? prefixIcon;

  /// Optional icon displayed at the end of the input.
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: hint,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
