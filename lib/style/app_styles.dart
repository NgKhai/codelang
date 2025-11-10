import 'package:flutter/material.dart';

import 'app_colors.dart';

// Defines specific TextStyles, utilizing AppColors.
class AppStyles {
  // Large Heading - typically used for the main screen title
  static const TextStyle headline1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // Subtitle/Section Title
  static const TextStyle subtitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  // Main Body Text - Default
  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  // Style for Text inside Buttons
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.backgroundLight, // Usually white/light color
  );
}