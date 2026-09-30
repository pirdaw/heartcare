import 'package:flutter/material.dart';

class ThemeService {
  ThemeService._();
  static final ThemeService instance = ThemeService._();

  static final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  static bool get isDarkMode =>
      themeModeNotifier.value == ThemeMode.dark;

  static void toggleTheme(bool isDark) {
    themeModeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}
