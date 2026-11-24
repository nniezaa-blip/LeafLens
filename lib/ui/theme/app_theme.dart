import 'package:flutter/widgets.dart';
import 'package:lextari/ui/tokens/app_colors.dart';
import 'package:prism_ui/prism_ui.dart' as prism;

class AppTheme {
  const AppTheme._();

  static prism.ThemeData prismLight() {
    return prism.ThemeData(
      colorScheme: prism.seededColorScheme(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
    );
  }

  static prism.ThemeData prismDark() {
    return prism.ThemeData(
      colorScheme: prism.seededColorScheme(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
    );
  }
}
