import 'package:nocab_desktop/services/registry/registry.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider(
      {this.themeMode = ThemeMode.light,
      this.seedColor = const Color(0xFF6750A4),
      this.useMaterial3 = false});
  ThemeMode themeMode;
  Color seedColor;
  bool useMaterial3;

  void toggleTheme() {
    themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  @Deprecated("this will be removed in production")
  void toggleSeedColor() {
    seedColor = seedColor == const Color(0xFF6750A4)
        ? RegistryService.getColor()
        : const Color(0xFF6750A4);
    notifyListeners();
  }

  void materialYou({bool value = true}) {
    useMaterial3 = value;
    notifyListeners();
  }

  void changeThemeMode(ThemeMode themeMode) {
    this.themeMode = themeMode;
    notifyListeners();
  }

  void changeSeedColor(Color color) {
    seedColor = color;
    notifyListeners();
  }
}
