import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nocab_desktop/models/file_model.dart';
import 'package:nocab_desktop/services/settings/settings.dart';
import 'package:path/path.dart' as p;

class FileOperations {
  static Future<void> tmpToFile(File thisFile) async {
    var lastSeparatorIndex = thisFile.path.lastIndexOf(Platform.pathSeparator);
    await thisFile.rename(thisFile.path.substring(0, lastSeparatorIndex + 1) +
        thisFile.path
            .substring(lastSeparatorIndex + 1)
            .replaceFirst('.nocabtmp', ''));
  }

  static String findUnusedFilePath(
      {required String fileName, required String downloadPath}) {
    int fileIndex = 0;
    String path;
    do {
      var indexOfLastDot = fileName.lastIndexOf('.');
      var fileNameWithoutExtension = fileName.substring(0, indexOfLastDot);
      var fileExtension = fileName.substring(indexOfLastDot);
      path = downloadPath +
          Platform.pathSeparator +
          fileNameWithoutExtension +
          (fileIndex == 0 ? '' : ' ($fileIndex)') +
          fileExtension;
      fileIndex++;
    } while (File(path).existsSync());
    return path;
  }

  static Future<List<FileInfo>> getFilesUnderDirectory(String path,
      [String? parentSubDirectory]) async {
    // open new thread to reduce cpu load
    return await compute(_getFilesUnderDirectory, [path, parentSubDirectory]);
  }

  static void openFile(FileInfo file) {
    String pathName = file.path!.substring(file.path!.lastIndexOf("\\") + 1);
    Process.start(pathName, [],
        workingDirectory: File(file.path!).parent.path, runInShell: true);
    // wait, is this working?
  }

  static void showInFolder(FileInfo file) {
    String pathName = file.path!.substring(file.path!.lastIndexOf("\\") + 1);
    if (Platform.isWindows)
      Process.start("explorer.exe", ["/select,", pathName],
          runInShell: true, workingDirectory: File(file.path!).parent.path);
    // TODO: show in folder on other platforms
  }

  static void openOutputFolder() {
    // create method checks if output folder exists and creates it if not, so no need to check output folder exists
    Directory(SettingsService().getSettings.downloadPath)
        .create(recursive: true)
        .then((value) {
      Process.run("start .", [],
          runInShell: true,
          workingDirectory: SettingsService().getSettings.downloadPath);
    });
  }

  static Future<List<FileInfo>> convertPathsToFileInfos(
      List<String> paths) async {
    // create a list contains all directories
    var directoryList = paths.fold(<Directory>[], (previousValue, path) {
      if (Directory(path).existsSync()) previousValue.add(Directory(path));
      return previousValue;
    });

    // create a list contains all files
    List<FileInfo> files = [];
    for (var filePath in paths.where((path) => File(path).existsSync())) {
      files.add(FileInfo(
          name: p.basename(filePath),
          byteSize: await File(filePath).length(),
          isEncrypted: false,
          hash: "test",
          path: filePath));
    }

    // add files under directories
    await Future.forEach(
        directoryList,
        (dir) async => files
            .addAll(await FileOperations.getFilesUnderDirectory(dir.path)));
    return files;
  }
}

Future<List<FileInfo>> _getFilesUnderDirectory(List<String?> args) async {
  var filesUnderDirectory = await Directory(args[0]!).list().toList();

  var files = <FileInfo>[];

  await Future.forEach(filesUnderDirectory, (element) async {
    String subDirectory =
        args[0]!.substring(args[0]!.lastIndexOf(Platform.pathSeparator) + 1);
    if ((await element.stat()).type == FileSystemEntityType.file) {
      var file = File(element.path);
      var fileInfo = FileInfo(
          name: file.path
              .substring(file.path.lastIndexOf(Platform.pathSeparator) + 1),
          byteSize: await file.length(),
          isEncrypted: false,
          hash: "null",
          path: file.path,
          subDirectory: p.join(args[1] ?? "", subDirectory));
      files.add(fileInfo);
    } else if ((await element.stat()).type == FileSystemEntityType.directory) {
      var subDirectoryFiles = await _getFilesUnderDirectory(
          [element.path, p.join(args[1] ?? "", subDirectory)]);
      files.addAll(subDirectoryFiles);
    }
  });

  return files;
}
