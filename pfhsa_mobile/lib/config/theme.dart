import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_controller.dart';

/// PFHSA design tokens — a "financial ledger" identity:
/// deep pine ink, brass accents, and pale sage paper, with a
/// serif display face for numbers/scores and a mono face for
/// amounts, evoking a hand-kept account book rather than a
/// generic finance-app dashboard.
///
/// Each color is a getter so it can swap between light/dark
/// variants live, driven by [ThemeController].
class AppColors {
  static bool get _dark => ThemeController.instance.isDark;

  static Color get ink => _dark ? const Color(0xFFEDEAE0) : const Color(0xFF16302B);
  static Color get paper => _dark ? const Color(0xFF12201C) : const Color(0xFFF2F1E6);
  static Color get paperDim => _dark ? const Color(0xFF1B2C26) : const Color(0xFFE8E6D6);
  static Color get brass => _dark ? const Color(0xFFD6A64A) : const Color(0xFFB8862E);
  static Color get pine => _dark ? const Color(0xFF5FB088) : const Color(0xFF3F7A5D);
  static Color get clay => _dark ? const Color(0xFFD06B4A) : const Color(0xFFA8492E);
  static Color get mutedInk => _dark ? const Color(0xFF86A099) : const Color(0xFF5C6B64);
  static Color get hairline => _dark ? const Color(0xFF2B3D36) : const Color(0xFFD6D3C2);
}

class AppTextStyles {
  static TextStyle display(double size, {Color? color, FontWeight? weight}) =>
      GoogleFonts.fraunces(
        fontSize: size,
        fontWeight: weight ?? FontWeight.w600,
        color: color ?? AppColors.ink,
        letterSpacing: -0.5,
      );

  static TextStyle body(double size, {Color? color, FontWeight? weight}) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight ?? FontWeight.w400,
        color: color ?? AppColors.ink,
      );

  static TextStyle mono(double size, {Color? color, FontWeight? weight}) =>
      GoogleFonts.ibmPlexMono(
        fontSize: size,
        fontWeight: weight ?? FontWeight.w500,
        color: color ?? AppColors.ink,
      );

  static TextStyle eyebrow(Color? color) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: color ?? AppColors.mutedInk,
      );
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: ThemeController.instance.isDark ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: AppColors.paper,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.pine,
      brightness: ThemeController.instance.isDark ? Brightness.dark : Brightness.light,
      primary: AppColors.pine,
      secondary: AppColors.brass,
      error: AppColors.clay,
      surface: AppColors.paper,
    ),
    textTheme: TextTheme(
      bodyMedium: AppTextStyles.body(14),
      bodyLarge: AppTextStyles.body(16),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.paper,
      foregroundColor: AppColors.ink,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.display(20),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.paperDim,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.pine, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.paper,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: AppTextStyles.body(15, weight: FontWeight.w600),
      ),
    ),
    dividerTheme: DividerThemeData(color: AppColors.hairline, thickness: 1),
  );
}
