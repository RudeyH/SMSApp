// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Riverpod 2.x Notifier-based provider that stores ThemeMode
/// and persists it using SharedPreferences.
final themeModeProvider =
NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);

class ThemeNotifier extends Notifier<ThemeMode> {
  static const _themeKey = 'themeMode'; // stored as int (ThemeMode.index)

  @override
  ThemeMode build() {
    // initial default. _loadTheme() will update `state` async if a value exists.
    _loadTheme();
    return ThemeMode.light;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final idx = prefs.getInt(_themeKey);
    if (idx != null && idx >= 0 && idx < ThemeMode.values.length) {
      final saved = ThemeMode.values[idx];
      if (state != saved) {
        state = saved;
      }
    }
  }

  /// Set a specific ThemeMode and persist it
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  /// Convenience helper to toggle between light/dark
  Future<void> toggleTheme(bool toDark) async {
    await setThemeMode(toDark ? ThemeMode.dark : ThemeMode.light);
  }
}




// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// // ✅ Using the correct syntax for Riverpod 2.x
// final themeModeProvider =
// NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);
//
// class ThemeNotifier extends Notifier<ThemeMode> {
//   static const _themeKey = 'themeMode';
//
//   @override
//   ThemeMode build() {
//     // Default theme
//     _loadTheme(); // load saved value asynchronously
//     return ThemeMode.light;
//   }
//
//   // 🔹 Load saved theme from SharedPreferences
//   Future<void> _loadTheme() async {
//     final prefs = await SharedPreferences.getInstance();
//     final themeIndex = prefs.getInt(_themeKey) ?? 0; // 0 = light, 1 = dark, 2 = system
//     final savedMode = ThemeMode.values[themeIndex];
//     if (state != savedMode) {
//       state = savedMode;
//     }
//   }
//
//   // 🔹 Toggle and save theme
//   Future<void> toggleTheme(bool isDark) async {
//     state = isDark ? ThemeMode.dark : ThemeMode.light;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt(_themeKey, state.index);
//   }
// }
