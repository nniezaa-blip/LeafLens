import 'package:flutter/widgets.dart';
import 'package:lextari/ui/tokens/app_colors.dart';
import 'package:prism_ui/prism_ui.dart' as prism;

class AppTheme {
  const AppTheme._();

  static prism.ThemeData prismLight() => _theme(Brightness.light);

  static prism.ThemeData prismDark() => _theme(Brightness.dark);

  static prism.ThemeData _theme(Brightness brightness) {
    final base = prism.seededColorScheme(
      seedColor: AppColors.moss,
      brightness: brightness,
    );
    final scheme = brightness == Brightness.light
        ? base.copyWith(
            primary: AppColors.moss,
            onPrimary: AppColors.paper,
            secondary: AppColors.leaf,
            onSecondary: AppColors.forest,
            surface: AppColors.paper,
            onSurface: AppColors.ink,
            onSurfaceVariant: AppColors.slate,
            error: AppColors.danger,
            onError: AppColors.paper,
            outline: AppColors.slate.withValues(alpha: 0.45),
          )
        : base.copyWith(
            primary: AppColors.lime,
            onPrimary: AppColors.forest,
            secondary: AppColors.leaf,
            onSecondary: AppColors.forest,
            surface: AppColors.forest,
            onSurface: AppColors.cream,
            onSurfaceVariant: AppColors.mist,
            error: AppColors.danger,
            onError: AppColors.paper,
            outline: AppColors.lime.withValues(alpha: 0.35),
          );
    return prism.ThemeData(
      colorScheme: scheme,
      fontFamily: 'Lexend',
      scaffoldBackgroundColor: brightness == Brightness.light
          ? AppColors.cream
          : AppColors.forest,
    );
  }
}
