import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nocab_core/nocab_core.dart';
import 'package:path/path.dart';
import 'package:nocab_logger/nocab_logger.dart';

class LogManager {
  static Stream<String> get onLog => NoCabCore.logger.onLogged.map((event) => event.toString());
  static Future<List<String>> get getCurrentLogs async => await NoCabCore.logger.file!.readAsLines();
  static File get currentLogFile => NoCabCore.logger.file!;

  static String get logFolderPath {
    if (Platform.isWindows && !kDebugMode) {
      return join(Platform.environment['APPDATA']!, 'NoCab Desktop', 'logs');
    }
    return join(File(Platform.resolvedExecutable).parent.path, 'logs');
  }

  static Future<void> cleanOldLogs() async {
    final Directory directory = Directory(logFolderPath);
    final List<FileSystemEntity> files = directory.listSync();
    final List<FileSystemEntity> oldFiles =
        files.where((element) => element.statSync().modified.isBefore(DateTime.now().subtract(const Duration(days: 7)))).toList();
    for (final FileSystemEntity file in oldFiles) {
      await file.delete();
    }
  }

  static Future<List<String>> getLogsFromFile(File file) async {
    if (await Logger.isFileValid(file)) {
      return await file.readAsLines();
    }
    throw const FormatException('File is not a valid log file');
  }

  static List<File> get getLogFiles {
    final Directory directory = Directory(logFolderPath);
    final List<FileSystemEntity> files = directory.listSync();
    return files.where((element) => element.statSync().type == FileSystemEntityType.file).cast<File>().toList();
  }

  static bool isFileValid(File file) => Logger.isFileValidSync(file);
}
