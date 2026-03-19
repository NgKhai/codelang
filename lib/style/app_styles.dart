import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

// Defines specific TextStyles, utilizing AppColors.
class AppStyles {
  // Large Heading
  static TextStyle get headline1 => GoogleFonts.outfit(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static TextStyle get headline1Dark => headline1.copyWith(
    color: AppColors.textPrimaryDark,
  );

  // Subtitle/Section Title
  static TextStyle get subtitle => GoogleFonts.outfit(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    color: AppColors.primary,
  );

  // Main Body Text
  static TextStyle get bodyText => GoogleFonts.inter(
    fontSize: 16,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyTextDark => bodyText.copyWith(
    color: AppColors.textPrimaryDark,
  );

  // Style for Text inside Buttons
  static TextStyle get buttonText => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: AppColors.textPrimaryDark,
  );
  
  // Smaller detail text
  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 13,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w500,
  );
}