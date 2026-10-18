import 'package:flutter/material.dart';

/// Brand palette taken from the CheckHER initial layout.
class AppColors {
  static const aqua = Color(0xFF00FFE1); // primary bright teal
  static const aquaSoft = Color(0xFFB8F5EC); // input borders, pills
  static const aquaPale = Color(0xFFCDF5EE); // pills on aqua cards
  static const mint = Color(0xFFE3FDF9); // screen background
  static const deepTeal = Color(0xFF0A7D6C); // reminder rings, play buttons
  static const ink = Color(0xFF111111);
  static const inkSoft = Color(0xFF555555);
  static const periodRed = Color(0xFFC0645A);
}

/// Soft teal-tinted shadow used on cards and tiles.
const softShadow = [
  BoxShadow(color: Color(0x220A7D6C), blurRadius: 14, offset: Offset(0, 5)),
];

const bodyFont = 'Poppins';
const displayFont = 'DMSerifDisplay';

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: bodyFont,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.aqua,
      primary: AppColors.deepTeal,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.mint,
  );
  OutlineInputBorder border(Color c) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: c, width: 1.6),
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.deepTeal,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF2FFFC),
      prefixIconColor: AppColors.deepTeal,
      hintStyle: const TextStyle(color: Color(0xFF7A8C89)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: border(AppColors.aquaSoft),
      enabledBorder: border(AppColors.aquaSoft),
      focusedBorder: border(AppColors.deepTeal),
      errorBorder: border(AppColors.periodRed),
      focusedErrorBorder: border(AppColors.periodRed),
    ),
  );
}

/// Serif display style for headings like "Todays Reminders".
const displayStyle = TextStyle(
  fontFamily: displayFont,
  fontWeight: FontWeight.w400,
  color: AppColors.ink,
  height: 1.15,
);
