import 'dart:io';

class UpdateVariables {
  Directory tempDirectory;
  Map latestRelease;
  String url;
  String signatureThumbprint;
  String signatureUrl;

  File updateFile;

  UpdateVariables(
      {required this.tempDirectory,
      required this.latestRelease,
      required this.url,
      required this.signatureThumbprint,
      required this.signatureUrl,
      required this.updateFile});
}
