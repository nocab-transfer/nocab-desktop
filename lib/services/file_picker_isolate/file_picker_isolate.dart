// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:isolate';

import 'package:file_picker/file_picker.dart';
import 'package:nocab_desktop/models/file_model.dart';

class _FilePickerIsolate {
  bool isIsolateRunning = false;

  Future<List<FileInfo>?> pickFilesIsolate() async {
    if (isIsolateRunning) return null;
    isIsolateRunning = true;

    ReceivePort isolateResponseReceiverPort = ReceivePort();
    Isolate.spawn(_pickFiles, [isolateResponseReceiverPort.sendPort]);

    var data = await isolateResponseReceiverPort.first;
    isIsolateRunning = false;
    return data;
  }
}

void _pickFiles(List<dynamic> args) async {
  SendPort mainReceiverPort = args[0];

  var response = await FilePicker.platform.pickFiles(allowMultiple: true);
  if (response is FilePickerResult)
    mainReceiverPort.send(response.files.map((file) => FileInfo(name: file.name, byteSize: file.size, path: file.path, hash: "unused", isEncrypted: false)).toList());
  else
    mainReceiverPort.send(null);
  Isolate.current.kill();
}

final filePicker = _FilePickerIsolate();
