import 'dart:io';

import 'package:nocab_core/nocab_core.dart';
import 'package:path/path.dart';

extension FileInfoFunctions on FileInfo {
  showInFolder() {
    Process.start("explorer.exe", ["/select,", basename(path!)], runInShell: true, workingDirectory: File(path!).parent.path);
  }

  openFile() {
    Process.start(basename(path!), [], workingDirectory: File(path!).parent.path, runInShell: true);
  }

  openWith() {
    Process.start("openwith.exe", [path!], runInShell: true, workingDirectory: File(path!).parent.path);
  }
}

extension FileFunctions on File {
  showInFolder() {
    Process.start("explorer.exe", ["/select,", basename(path)], runInShell: true, workingDirectory: File(path).parent.path);
  }

  openFile() {
    Process.start(basename(path), [], workingDirectory: File(path).parent.path, runInShell: true);
  }

  openWith() {
    Process.start("openwith.exe", [path], runInShell: true, workingDirectory: File(path).parent.path);
  }
}
