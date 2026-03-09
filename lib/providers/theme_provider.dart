import 'package:flutter/material.dart';

/// Manages the app's theme state (light, dark, or system default) and notifies listeners when theme changes.
class ThemeProvider extends ChangeNotifier {
  /// Current theme mode selected by the user.
  ThemeMode _themeMode = ThemeMode.system;

  /// Getter to retrieve the current theme mode throughout the app.
  ThemeMode get themeMode => _themeMode;

  /// Updates the theme mode and notifies all listeners to rebuild with the new theme.
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  /// Cycles through theme modes: light → dark → light, allowing quick theme toggling from the UI.
  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
    } else {
      // If system, switch to light
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  /// Returns true if dark theme is currently active, useful for conditional UI logic based on theme.
  bool get isDarkMode {
    return _themeMode == ThemeMode.dark;
  }
}
