import 'dart:math';

extension Format on int {
  String formatBytes({bool useName = false}) {
    if (this <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    const names = ["Byte", "Kilobyte", "Megabyte", "Gigabyte", "Terabyte", "Petabyte", "Exabyte", "Zettabyte", "Yottabyte"];
    var i = (log(this) / log(1000)).floor();
    return '${(this / pow(1000, i)).toStringAsFixed(2)} ${useName ? names[i] : suffixes[i]}';
  }
}

extension FormatDouble on double {
  String formatBytes({bool useName = false}) {
    if (this <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    const names = ["Byte", "Kilobyte", "Megabyte", "Gigabyte", "Terabyte", "Petabyte", "Exabyte", "Zettabyte", "Yottabyte"];
    var i = (log(this) / log(1000)).floor();
    return '${(this / pow(1000, i)).toStringAsFixed(2)} ${useName ? names[i] : suffixes[i]}';
  }
}

extension ConvertSizes on int {
  int get gbToBytes => this * 1000 * 1000 * 1000;
}
