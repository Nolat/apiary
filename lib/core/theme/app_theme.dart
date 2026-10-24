// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:apiary/core/theme/app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get game => ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          surface: AppColors.surface,
          primary: AppColors.accent,
          onSurface: AppColors.honey,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(color: AppColors.honey),
          bodyMedium: TextStyle(color: AppColors.honey),
        ),
      );
}
