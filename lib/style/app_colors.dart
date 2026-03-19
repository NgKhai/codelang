import 'package:flutter/material.dart';

// Defines all raw Hex or RGB color codes.
class AppColors {
  // Primary Colors (Original)
  static const Color primary = Color(0xFF4A90E2); // CodeLang Blue
  static const Color accent = Color(0xFF50E3C2);  // Teal Accent

  // Background Colors
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color backgroundDark = Color(0xFF121212);

  // Surface Colors for Glassmorphism (Cards)
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color glassWhite = Color(0x33FFFFFF); // 20% white
  static const Color glassBlack = Color(0x33000000); // 20% black
  
  // Status/Feedback Colors
  static const Color success = Color(0xFF7ED321);
  static const Color error = Color(0xFFD0021B);
  static const Color warning = Color(0xFFF5A623);

  // Text Colors
  static const Color textPrimary = Color(0xFF333333); 
  static const Color textPrimaryDark = Color(0xFFFFFFFF); 
  static const Color textSecondary = Color(0xFF888888); 
}