import 'package:flutter/material.dart';

extension LangToName on Locale {
  String get langName {
    switch ("$languageCode${countryCode != null ? "-$countryCode" : ""}") {
      case 'en': return "English";
      case 'tr': return "Türkçe";
      case 'zh-CN': return "简体中文";
      default: return languageCode;
    }
  }
}
