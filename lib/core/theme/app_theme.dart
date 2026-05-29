import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryContainer,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Color(0xFF003826),
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: Color(0xFF98EDC6),
        secondary: AppColors.secondary,
        onSecondary: Color(0xFF003826),
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: Color(0xFFBAFFDC),
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        outline: AppColors.outline,
      ),
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.headlineLarge.copyWith(color: AppColors.onSurface),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(color: AppColors.onSurface),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurface),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.onSurfaceVariant),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
        displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.onSurface),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.onSurface),
        titleTextStyle: TextStyle(color: AppColors.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryContainer, width: 2),
        ),
        labelStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.onSurfaceVariant),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.3)),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.ivory,
      primaryColor: AppColors.primaryContainer,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryContainer,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFF98EDC6),
        onPrimaryContainer: AppColors.primaryContainer,
        secondary: AppColors.secondaryContainer,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFBAFFDC),
        onSecondaryContainer: AppColors.secondaryContainer,
        surface: AppColors.pureWhite,
        onSurface: Color(0xFF101412),
        onSurfaceVariant: Color(0xFF507060),
        error: AppColors.alertRed,
        onError: Colors.white,
        outline: Color(0xFF172C20),
      ),
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.headlineLarge.copyWith(color: const Color(0xFF101412)),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(color: const Color(0xFF101412)),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: const Color(0xFF101412)),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: const Color(0xFF101412)),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF507060)),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: const Color(0xFF507060)),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: const Color(0xFF507060)),
        displayLarge: AppTextStyles.displayLarge.copyWith(color: const Color(0xFF101412)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Color(0xFF101412)),
        titleTextStyle: TextStyle(color: Color(0xFF101412), fontSize: 20, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardThemeData(
        color: AppColors.pureWhite,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.05), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.pureWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryContainer, width: 2),
        ),
        labelStyle: AppTextStyles.labelMedium.copyWith(color: const Color(0xFF507060)),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: const Color(0xFF507060).withValues(alpha: 0.5)),
      ),
    );
  }
}
