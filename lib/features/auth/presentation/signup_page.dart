import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lextari/core/errors/error_handler.dart';
import 'package:lextari/core/errors/failures.dart';
import 'package:lextari/core/utils/validators.dart';
import 'package:lextari/features/auth/domain/auth_actions.dart';
import 'package:lextari/ui/ui.dart';
import 'package:lextari/widgets/app_text_field.dart';

extension on BuildContext {
  TextStyle get signUpTitleStyle => const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 30,
    color: AppColors.deepGreen,
  );

  TextStyle get googleButtonStyle => const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: AppColors.offWhite,
  );

  TextStyle get signUpButtonStyle =>
      const TextStyle(fontWeight: FontWeight.w600, fontSize: 22);

  TextStyle get termsMuted => const TextStyle(
    fontWeight: FontWeight.w300,
    fontSize: 16,
    color: AppColors.offBlack,
  );

  TextStyle get termsLink => const TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 16,
    color: AppColors.redDark,
  );

  TextStyle get loginMuted => TextStyle(
    fontWeight: FontWeight.w300,
    fontSize: 16,
    color: AppColors.offBlack.withValues(alpha: 0.6),
  );

  TextStyle get loginLink => const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 16,
    color: AppColors.mediumGreen,
  );
}

/// Sign-up screen with full name, email, phone, password fields
/// and terms-of-service acceptance.
class SignUpPage extends ConsumerStatefulWidget {
  /// Creates a [SignUpPage] widget.
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _agreeToTerms = false;
  bool _loading = false;
  String? _formError;
  String? _termsError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      setState(() => _termsError = 'Please accept the terms to continue.');
      return;
    }

    setState(() {
      _loading = true;
      _formError = null;
      _termsError = null;
    });

    try {
      await ref
          .read(authActionsProvider)
          .register(_emailCtrl.text.trim(), _passwordCtrl.text);
      if (mounted) context.go('/dashboard');
    } on AuthFailure catch (e) {
      setState(() => _formError = e.message);
    } on Failure catch (e) {
      ErrorHandler.handle(e);
    } on Exception catch (e) {
      ErrorHandler.handle(UnknownFailure(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() {
      _loading = true;
      _formError = null;
      _termsError = null;
    });

    try {
      final signedIn = await ref.read(authActionsProvider).signInWithGoogle();
      if (mounted && signedIn) context.go('/dashboard');
    } on AuthFailure catch (e) {
      setState(() => _formError = e.message);
    } on Failure catch (e) {
      ErrorHandler.handle(e);
    } on Exception catch (e) {
      ErrorHandler.handle(UnknownFailure(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PrismScaffold(
      bar: const EmptyBar(),
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
                  const Center(child: _SignUpHeader()),
                  _GoogleSignUpButton(
                    loading: _loading,
                    onPressed: _handleGoogleSignUp,
                  ),
                  const _OrDivider(),
                  _NameField(controller: _nameCtrl),
                  const SizedBox(height: 12),
                  _EmailField(controller: _emailCtrl),
                  const SizedBox(height: 12),
                  _PhoneField(controller: _phoneCtrl),
                  const SizedBox(height: 12),
                  _PasswordField(
                    controller: _passwordCtrl,
                    obscure: _obscurePassword,
                    onToggle: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  const SizedBox(height: 20),
                  _TermsCheckbox(
                    agreed: _agreeToTerms,
                    onChanged: (v) {
                      setState(() {
                        _agreeToTerms = v;
                        _termsError = null;
                      });
                    },
                    error: _termsError,
                  ),
                  if (_formError != null) ...[
                    const SizedBox(height: 12),
                    _FormErrorBanner(message: _formError!),
                  ],
                  const SizedBox(height: 20),
                  _SignUpButton(loading: _loading, onPressed: _handleSignUp),
                  const SizedBox(height: 16),
                  const _LoginRow(),
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

class _SignUpHeader extends StatelessWidget {
  const _SignUpHeader();

  @override
  Widget build(BuildContext context) {
    return Text('Sign up', style: context.signUpTitleStyle);
  }
}

class _GoogleSignUpButton extends StatelessWidget {
  const _GoogleSignUpButton({required this.loading, required this.onPressed});

  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              const SizedBox(
                width: 20,
                height: 20,
                child: ActivityIndicator(
                  size: 20,
                  color: AppColors.white,
                ),
              )
            else
              SvgPicture.asset(
                'assets/images/google_logo.svg',
                width: 22,
                height: 22,
              ),
            const SizedBox(width: 12),
            Text('Sign up with Google', style: context.googleButtonStyle),
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
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: AppColors.greyLighter)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Or continue with Email',
              style: DefaultTextStyle.of(context).style.copyWith(
                color: AppColors.textGrey,
              ),
            ),
          ),
          Expanded(child: Container(height: 1, color: AppColors.greyLighter)),
        ],
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      hint: 'Full Name',
      controller: controller,
      validator: (v) => (v == null || v.isEmpty) ? 'Enter your name' : null,
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

class _PhoneField extends StatelessWidget {
  const _PhoneField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      hint: 'Phone Number',
      controller: controller,
      keyboardType: TextInputType.phone,
      validator: (v) =>
          (v == null || v.isEmpty) ? 'Enter your phone number' : null,
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
      suffixIcon: IconTap(
        icon: GlyphIcon(
          obscure ? AppGlyphs.visibilityOff : AppGlyphs.visibility,
        ),
        onPressed: onToggle,
      ),
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({
    required this.agreed,
    required this.onChanged,
    this.error,
  });
  final bool agreed;
  final ValueChanged<bool> onChanged;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: agreed,
                onChanged: (v) => onChanged(v ?? false),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: context.termsMuted,
                  children: [
                    const TextSpan(text: 'I accept '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: context.termsLink,
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: context.termsLink,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(left: 34, top: 4),
            child: Text(
              error!,
              style: const TextStyle(
                color: AppColors.redDark,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

class _SignUpButton extends StatelessWidget {
  const _SignUpButton({required this.loading, required this.onPressed});
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: ActivityIndicator(
                size: 20,
                color: AppColors.offWhite,
              ),
            )
          : Text('Sign Up', style: context.signUpButtonStyle),
    );
  }
}

class _LoginRow extends StatelessWidget {
  const _LoginRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Already have an account? ', style: context.loginMuted),
        GestureDetector(
          onTap: () => context.go('/login'),
          child: Text('Login', style: context.loginLink),
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
