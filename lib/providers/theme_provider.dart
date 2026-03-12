// import 'package:flutter/material.dart';

// /// Manages the app's theme state (light, dark, or system default) and notifies listeners when theme changes.
// class ThemeProvider extends ChangeNotifier {
//   /// Current theme mode selected by the user.
//   ThemeMode _themeMode = ThemeMode.system;

//   /// Getter to retrieve the current theme mode throughout the app.
//   ThemeMode get themeMode => _themeMode;

//   /// Updates the theme mode and notifies all listeners to rebuild with the new theme.
//   void setThemeMode(ThemeMode mode) {
//     _themeMode = mode;
//     notifyListeners();
//   }

//   /// Cycles through theme modes: light → dark → light, allowing quick theme toggling from the UI.
//   void toggleTheme() {
//     if (_themeMode == ThemeMode.light) {
//       _themeMode = ThemeMode.dark;
//     } else if (_themeMode == ThemeMode.dark) {
//       _themeMode = ThemeMode.light;
//     } else {
//       // If system, switch to light
//       _themeMode = ThemeMode.light;
//     }
//     notifyListeners();
//   }

//   /// Returns true if dark theme is currently active, useful for conditional UI logic based on theme.
//   bool get isDarkMode {
//     return _themeMode == ThemeMode.dark;
//   }
// }


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the app's theme state (light or dark) and persists it using SharedPreferences.
class ThemeProvider extends ChangeNotifier {
  // 1. Change default from system to light
  ThemeMode _themeMode = ThemeMode.light; 

  // Key used to store the preference
  static const String _themePrefKey = 'isDarkMode';

  /// Getter to retrieve the current theme mode throughout the app.
  ThemeMode get themeMode => _themeMode;

  /// Constructor loads the saved theme when the provider is initialized.
  ThemeProvider() {
    _loadFromPrefs();
  }

  /// Loads the theme from SharedPreferences
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    // Get the saved boolean. If it doesn't exist yet, default to false (light mode).
    final isDark = prefs.getBool(_themePrefKey) ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Saves the current theme to SharedPreferences
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themePrefKey, _themeMode == ThemeMode.dark);
  }

  /// Updates the theme mode, notifies listeners, and saves the new choice.
  void setThemeMode(ThemeMode mode) {
    // Prevent setting to system entirely
    if (mode == ThemeMode.system) return; 
    
    _themeMode = mode;
    _saveToPrefs();
    notifyListeners();
  }

  /// Cycles through theme modes: light → dark → light.
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveToPrefs();
    notifyListeners();
  }

  /// Returns true if dark theme is currently active.
  bool get isDarkMode => _themeMode == ThemeMode.dark;
}