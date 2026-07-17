import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

/// Central app theme for the SIORG visual refresh.
///
/// Phase 1: applied at the [MaterialApp] root. Existing screens keep their
/// inline colors and will continue to look the same except for the global
/// font (Plus Jakarta Sans) and scaffold background. Migrate screens to the
/// tokens in [AppColors] incrementally (Phase 2).
class AppTheme {
  AppTheme._();

  /// Card / sheet radii from the handoff (§1 Bentuk & jarak).
  static const double cardRadius = 20;
  static const double sheetRadius = 30;

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.navy,
        onPrimary: Colors.white,
        secondary: AppColors.red,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.ink,
        error: AppColors.danger,
      ),
    );

    return base.copyWith(
      // Plus Jakarta Sans applied over the platform text theme.
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      dividerColor: AppColors.line,
    );
  }
}
