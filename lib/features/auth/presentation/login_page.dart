import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lextari/core/errors/error_handler.dart';
import 'package:lextari/core/errors/failures.dart';
import 'package:lextari/core/theme/app_colors.dart';
import 'package:lextari/core/utils/validators.dart';
import 'package:lextari/features/auth/data/auth_repository.dart';
import 'package:lextari/shared/widgets/app_text_field.dart';

/// Per-screen extensions keep build() readable without
/// global namespace pollution.
extension on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  TextStyle get loginTitleStyle => const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 46,
    color: AppColors.deepGreen,
  );

  TextStyle get googleButtonStyle => const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: AppColors.white,
  );

  TextStyle get loginButtonStyle =>
      const TextStyle(fontWeight: FontWeight.w600, fontSize: 20);

  TextStyle get signUpMuted => TextStyle(
    fontWeight: FontWeight.w300,
    fontSize: 16,
    color: AppColors.offBlack.withValues(alpha: 0.6),
  );

  TextStyle get signUpLink => const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 16,
    color: AppColors.mediumGreen,
  );
}

/// Login screen with email/password form and Google sign-in placeholder.
class LoginPage extends ConsumerStatefulWidget {
  /// Creates a [LoginPage] widget.
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;
  String? _formError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _formError = null;
    });

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.login(_emailCtrl.text.trim(), _passwordCtrl.text);
      if (mounted) context.go('/dashboard');
    } on AuthFailure catch (e) {
      // Inline: stay on form so user can retry immediately.
      setState(() => _formError = e.message);
    } on Failure catch (e) {
      // All other failures go through the central handler (toast + metrics).
      ErrorHandler.handle(e);
    } on Exception catch (e) {
      ErrorHandler.handle(UnknownFailure(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Center(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: _LoginHeader()),
                  const _GoogleSignInButton(),
                  const _OrDivider(),
                  _EmailField(controller: _emailCtrl),
                  const SizedBox(height: 12),
                  _PasswordField(
                    controller: _passwordCtrl,
                    obscure: _obscurePassword,
                    onToggle: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  if (_formError != null) ...[
                    const SizedBox(height: 12),
                    _FormErrorBanner(message: _formError!),
                  ],
                  const SizedBox(height: 20),
                  _LoginButton(loading: _loading, onPressed: _handleLogin),
                  const SizedBox(height: 12),
                  const _SignUpRow(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//
// Private widgets
//

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return Text('Login', style: context.loginTitleStyle);
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: FilledButton.tonal(
        onPressed: () => throw UnimplementedError('Google sign-in'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.offBlack,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/google_logo.svg',
              width: 22,
              height: 22,
            ),
            const SizedBox(width: 12),
            Text('Log in with Google', style: context.googleButtonStyle),
          ],
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Row(
        children: [
          Expanded(child: Divider(color: context.colors.outlineVariant)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Or continue with Email',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.outline,
              ),
            ),
          ),
          Expanded(child: Divider(color: context.colors.outlineVariant)),
        ],
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      hint: 'Email',
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      validator: Validators.email,
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggle,
  });
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      hint: 'Password',
      controller: controller,
      obscureText: obscure,
      validator: (v) => (v == null || v.isEmpty) ? 'Enter your password' : null,
      suffixIcon: IconButton(
        icon: Icon(
          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        ),
        onPressed: onToggle,
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.loading, required this.onPressed});
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: loading ? null : onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: const StadiumBorder(),
      ),
      child: loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.offWhite,
              ),
            )
          : Text('Login', style: context.loginButtonStyle),
    );
  }
}

class _SignUpRow extends StatelessWidget {
  const _SignUpRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account? ", style: context.signUpMuted),
        GestureDetector(
          onTap: () => context.go('/signup'),
          child: Text('Sign up', style: context.signUpLink),
        ),
      ],
    );
  }
}

/// Red error text shown above the submit button on form failures.
class _FormErrorBanner extends StatelessWidget {
  const _FormErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(
        color: AppColors.redDark,
        fontSize: 14,
      ),
    );
  }
}
