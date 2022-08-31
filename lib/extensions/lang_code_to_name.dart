extension LangCodeToName on String {
  String get langName {
    switch (this) {
      case 'en':
        return "English";
      default:
        // ignore: recursive_getters
        return langName;
    }
  }
}
