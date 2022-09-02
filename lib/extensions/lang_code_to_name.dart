extension LangCodeToName on String {
  String get langName {
    switch (this) {
      case 'en':
        return "English";
      case 'tr':
        return "Türkçe";
      default:
        return this;
    }
  }
}
