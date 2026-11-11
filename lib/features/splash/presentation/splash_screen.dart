import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lextari/core/theme/app_colors.dart';
import 'package:lextari/shared/widgets/background_ellipse.dart';
import 'package:lextari/shared/widgets/lextari_logo.dart';

/// Per-screen extensions keep build() readable without
/// global namespace pollution.
extension on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  void navigateTo(String route) => go(route);

  TextStyle get brandStyle => const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 28,
    color: AppColors.offWhite,
  );

  TextStyle get taglineStyle => const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 26,
    color: AppColors.offWhite,
    fontStyle: FontStyle.italic,
  );
  TextStyle get buttonStyle => const TextStyle(
    fontWeight: FontWeight.w800,
    fontSize: 22,
    color: AppColors.offWhite,
  );
}

/// Splash / onboarding screen shown on every launch.
///
/// Displays the brand logo, tagline, and a "Get Started" button.
/// After [displayDuration] it advances on its own — the auth guard
/// then routes signed-in users to the dashboard and guests to login.
/// Tapping "Get Started" skips the wait.
class SplashScreen extends StatefulWidget {
  /// Creates a [SplashScreen] widget.
  const SplashScreen({super.key});

  /// How long the splash stays visible before routing onward.
  static const Duration displayDuration = Duration(seconds: 2);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(SplashScreen.displayDuration, _proceed);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Advances past the splash. Navigation targets `/login`; the auth
  /// guard redirects signed-in users on to `/dashboard`.
  void _proceed() {
    if (!mounted) return;
    _timer?.cancel();
    if (GoRouter.maybeOf(context) != null) context.navigateTo('/login');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.lightGreenBg,
      body: Stack(
        children: [
          BackgroundEllipse(),
          SafeArea(child: _SplashContent()),
        ],
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 3),
        const LextariLogo(),
        const SizedBox(height: 16),
        Text('LEXTARI', style: context.brandStyle),
        const SizedBox(height: 12),
        Text(
          'Smarter Care for\nHealthier Plants',
          textAlign: TextAlign.center,
          style: context.taglineStyle,
        ),
        const Spacer(flex: 3),
        const _GetStartedButton(),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _GetStartedButton extends StatelessWidget {
  const _GetStartedButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () => context.navigateTo('/login'),
          style: FilledButton.styleFrom(
            backgroundColor: context.colors.primary,
            foregroundColor: context.colors.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: const StadiumBorder(),
          ),
          child: Text('Get Started', style: context.buttonStyle),
        ),
      ),
    );
  }
}
