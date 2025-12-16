import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/services/theme_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final ThemeLocalDataSource _dataSource;

  // Initialize with system default and load persisted value
  ThemeCubit(this._dataSource) : super(ThemeMode.dark) {
    _loadInitialTheme();
  }

  /// Loads the saved theme choice from storage upon initialization.
  void _loadInitialTheme() async {
    final savedMode = await _dataSource.getSavedThemeMode();
    emit(savedMode);
  }

  /// Toggles the theme between light and dark, and saves the new choice.
  void toggleTheme() {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    emit(newMode);
    _dataSource.saveThemeMode(newMode);
  }

  /// Explicitly set theme mode (useful for complex settings screen)
  void setTheme(ThemeMode mode) {
    emit(mode);
    _dataSource.saveThemeMode(mode);
  }
}