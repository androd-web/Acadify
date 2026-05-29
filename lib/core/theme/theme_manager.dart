import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ValueNotifier<ThemeMode> {
  static const String _themeKey = 'theme_mode';
  late SharedPreferences _prefs;

  ThemeManager() : super(ThemeMode.system);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final String? themeValue = _prefs.getString(_themeKey);
    
    if (themeValue != null) {
      value = ThemeMode.values.firstWhere(
        (e) => e.toString() == themeValue,
        orElse: () => ThemeMode.system,
      );
    }
  }

  void setTheme(ThemeMode mode) {
    value = mode;
    _prefs.setString(_themeKey, mode.toString());
  }

  bool get isDarkMode => value == ThemeMode.dark;
  bool get isSystemMode => value == ThemeMode.system;
}

final themeManager = ThemeManager();
