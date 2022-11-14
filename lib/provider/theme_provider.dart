import 'package:nocab_desktop/services/registry/registry.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider({this.themeMode = ThemeMode.light, this.seedColor = const Color(0xFF6750A4)});
  ThemeMode themeMode;
  Color seedColor;

  void toggleTheme() {
    themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  @Deprecated("this will be removed in production")
  void toggleSeedColor() {
    seedColor = seedColor == const Color(0xFF6750A4) ? RegistryService.getColor() : const Color(0xFF6750A4);
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
