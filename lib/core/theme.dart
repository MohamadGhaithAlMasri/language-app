import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF054533); // Deep Green
  static const Color primaryLight = Color(0xFFE6EFEA); // Light Green tint
  static const Color accent = Color(0xFFB89047); // Gold / Sand
  static const Color accentLight = Color(0xFFFAF6EE); // Very light gold
  
  static const Color background = Color(0xFFF7F8FA);
  static const Color cardBg = Colors.white;
  
  static const Color textDark = Color(0xFF1E293B);
  static const Color textLight = Color(0xFF64748B);
  static const Color textWhite = Colors.white;
  
  static const Color success = Color(0xFF10B981);
  static const Color successBg = Color(0xFFECFDF5);
  static const Color error = Color(0xFFEF4444);
  static const Color errorBg = Color(0xFFFEF2F2);
  
  static const Color border = Color(0xFFE2E8F0);
}

ThemeData getAppTheme() {
  final baseTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.background,
    ),
  );

  return baseTheme.copyWith(
    textTheme: GoogleFonts.cairoTextTheme(baseTheme.textTheme).copyWith(
      displayLarge: GoogleFonts.cairo(
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
      titleLarge: GoogleFonts.cairo(
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
      bodyLarge: GoogleFonts.cairo(
        color: AppColors.textDark,
      ),
      bodyMedium: GoogleFonts.cairo(
        color: AppColors.textLight,
      ),
    ),
  );
}
