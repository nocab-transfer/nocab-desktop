import 'dart:io';

import 'package:flutter/material.dart';
import 'package:win32_registry/win32_registry.dart';

class RegistryService {
  static Color getColor() {
    if (Platform.isWindows) {
      final key = Registry.openPath(RegistryHive.currentUser, path: r'Software\Microsoft\Windows\DWM');
      final value = key.getValueAsInt('ColorizationColor');
      key.close();
      if (value == null) return const Color(0xFF6750A4);
      return Color(value);
    } else {
      // TODO: implement for other platforms
      return const Color(0xFF6750A4);
    }
  }

  static bool isDarkMode() {
    if (Platform.isWindows) {
      final key = Registry.openPath(RegistryHive.currentUser, path: r'Software\Microsoft\Windows\CurrentVersion\Themes\Personalize');
      final value = key.getValueAsInt('AppsUseLightTheme');
      key.close();
      if (value == null || value == 1) return false;
      return true;
    } else {
      return false;
    }
  }
}
