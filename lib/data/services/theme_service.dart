import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeLocalDataSource {
  static const String _themeModeKey = 'theme_mode_key';

  /// Loads the saved ThemeMode string from SharedPreferences.
  /// Defaults to 'system' if not found.
  Future<ThemeMode> getSavedThemeMode() async {

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? savedMode = prefs.getString(_themeModeKey);

      if (savedMode == 'light') {
        return ThemeMode.light;
      } else if (savedMode == 'dark') {
        return ThemeMode.dark;
      }
      return ThemeMode.dark; // Default
    } catch (e) {
      // Log error and return system default if storage fails
      debugPrint('Error loading theme mode: $e');
      return ThemeMode.dark;
    }
  }

  /// Saves the current ThemeMode choice to SharedPreferences.
  Future<void> saveThemeMode(ThemeMode mode) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String modeString = mode.toString().split('.').last;
      await prefs.setString(_themeModeKey, modeString);
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }
}