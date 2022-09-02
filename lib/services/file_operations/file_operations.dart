import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nocab_desktop/models/file_model.dart';
import 'package:path/path.dart' as p;

class FileOperations {
  static Future<void> tmpToFile(File thisFile) async {
    var lastSeparatorIndex = thisFile.path.lastIndexOf(Platform.pathSeparator);
    await thisFile.rename(thisFile.path.substring(0, lastSeparatorIndex + 1) + thisFile.path.substring(lastSeparatorIndex + 1).replaceFirst('.nocabtmp', ''));
  }

  static String findUnusedFilePath({required String fileName, required String downloadPath}) {
    int fileIndex = 0;
    String path;
    do {
      var indexOfLastDot = fileName.lastIndexOf('.');
      var fileNameWithoutExtension = fileName.substring(0, indexOfLastDot);
      var fileExtension = fileName.substring(indexOfLastDot);
      path = downloadPath + Platform.pathSeparator + fileNameWithoutExtension + (fileIndex == 0 ? '' : ' ($fileIndex)') + fileExtension;
      fileIndex++;
    } while (File(path).existsSync());
    return path;
  }

  static Future<List<FileInfo>> getFilesUnderDirectory(String path, [String? parentSubDirectory]) async {
    // open new thread to reduce cpu load
    return await compute(_getFilesUnderDirectory, [path, parentSubDirectory]);
  }

  static void openFile(FileInfo file) {
    String pathName = file.path!.substring(file.path!.lastIndexOf("\\") + 1);
    Process.start(pathName, [], workingDirectory: File(file.path!).parent.path, runInShell: true);
    // wait, is this working?
  }

  static void showInFolder(FileInfo file) {
    String pathName = file.path!.substring(file.path!.lastIndexOf("\\") + 1);
    if (Platform.isWindows) Process.start("explorer.exe", ["/select,", pathName], runInShell: true, workingDirectory: File(file.path!).parent.path);
    // TODO: show in folder on other platforms
  }

  static void openOutputFolder() {
    // create method checks if output folder exists and creates it if not, so no need to check output folder exists
    Directory("${File(Platform.resolvedExecutable).parent.path}\\output").create(recursive: true).then((value) {
      Process.run("start .", [], runInShell: true, workingDirectory: "${File(Platform.resolvedExecutable).parent.path}\\output");
    });
  }

  /// If the path does not specify a file, remove the file from the list
  static Future<List<FileInfo>> cleanFiles(List<FileInfo> files) async {
    for (FileInfo file in files) {
      if (!(await FileSystemEntity.isFile(file.path!))) files.remove(file);
    }
    return files;
  }
}

Future<List<FileInfo>> _getFilesUnderDirectory(List<String?> args) async {
  var filesUnderDirectory = await Directory(args[0]!).list().toList();

  var files = <FileInfo>[];

  await Future.forEach(filesUnderDirectory, (element) async {
    String subDirectory = args[0]!.substring(args[0]!.lastIndexOf(Platform.pathSeparator) + 1);
    if ((await element.stat()).type == FileSystemEntityType.file) {
      var file = File(element.path);
      var fileInfo = FileInfo(name: file.path.substring(file.path.lastIndexOf(Platform.pathSeparator) + 1), byteSize: await file.length(), isEncrypted: false, hash: "null", path: file.path, subDirectory: p.join(args[1] ?? "", subDirectory));
      files.add(fileInfo);
    } else if ((await element.stat()).type == FileSystemEntityType.directory) {
      var subDirectoryFiles = await _getFilesUnderDirectory([element.path, p.join(args[1] ?? "", subDirectory)]);
      files.addAll(subDirectoryFiles);
    }
  });

  return files;
}
