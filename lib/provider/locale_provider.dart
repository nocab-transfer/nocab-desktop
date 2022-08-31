import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  late Locale _locale;
  late final List<Locale> _supportedLocales;
  LocaleProvider(this._locale, this._supportedLocales);

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!_supportedLocales.contains(locale)) return;

    _locale = locale;
    notifyListeners();
  }
}
