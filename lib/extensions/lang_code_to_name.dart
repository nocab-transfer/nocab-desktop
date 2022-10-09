import 'package:flutter/material.dart';

extension LangToName on Locale {
  String get langName {
    switch (languageCode) {
      case 'en':
        return "English";
      case 'tr':
        return "Türkçe";
      default:
        return languageCode;
    }
  }
}
