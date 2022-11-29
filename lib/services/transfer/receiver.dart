import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:nocab_desktop/models/deviceinfo_model.dart';
import 'package:nocab_desktop/models/file_model.dart';
import 'package:nocab_desktop/services/file_operations/file_operations.dart';
import 'package:nocab_desktop/services/transfer/isolate_message.dart';
import 'package:nocab_desktop/services/transfer/report_models/base_report.dart';
import 'package:nocab_desktop/services/transfer/report_models/data_report.dart';
import 'package:nocab_desktop/services/transfer/report_models/end_report.dart';
import 'package:nocab_desktop/services/transfer/report_models/error_report.dart';
import 'package:nocab_desktop/services/transfer/report_models/fileend_report.dart';
import 'package:nocab_desktop/services/transfer/report_models/start_report.dart';
import 'package:nocab_desktop/services/transfer/transfer.dart';

class Receiver extends Transfer {
  Receiver({
    required DeviceInfo deviceInfo,
    required List<FileInfo> files,
    required int transferPort,
    required String uniqueId,
  }) : super(deviceInfo: deviceInfo, files: files, transferPort: transferPort, uniqueId: uniqueId);

  @override
  Future<void> start() async {
    ReceivePort dataToMainPort = ReceivePort();
    await Isolate.spawn(_dataHandler, [
      dataToMainPort.sendPort,
      files,
      deviceInfo,
      transferPort,
    ]);

    SendPort? mainToDataPort; // this will be used for pausing and resuming the transfer
    mainToDataPort;
    dataToMainPort.listen((message) {
      if (message is SendPort) mainToDataPort = message;

      if (message is Report) eventController.add(message..transferUuid = uniqueId);
      if (message is ErrorReport || message is EndReport) {
        ongoing = false;
        dataToMainPort.close();
        eventController.close();
      }
    });
  }
}

void _dataHandler(List<dynamic> args) async {
  SendPort dataToMainSendPort = args[0];

  ReceivePort mainToDataPort = ReceivePort();
  dataToMainSendPort.send(mainToDataPort.sendPort);

  List<FileInfo> files = args[1];
  List<FileInfo> filesTransferred = [];
  FileInfo currentFile = files.first;

  DeviceInfo deviceInfo = args[2];

  final int port = args[3];

  Isolate? receiverIsolate;

  dataToMainSendPort.send(StartReport(startTime: DateTime.now(), deviceInfo: deviceInfo, files: files));

  int totalByteCount = 0;
  int totalByteCountBefore = 0;
  const Duration duration = Duration(milliseconds: 100);

  const int errorHandleTimeoutMilliseconds = 30000;
  int currentErrorTime = 0;

  Timer.periodic(duration, (timer) {
    dataToMainSendPort.send(
      DataReport(
        files: files,
        filesTransferred: filesTransferred,
        currentFile: currentFile,
        speed: ((totalByteCount - totalByteCountBefore) * 1000 / duration.inMilliseconds) / 1024 / 1024,
        progress: (100 * totalByteCount / currentFile.byteSize) > 100 ? 100 : (100 * totalByteCount / currentFile.byteSize),
        deviceInfo: deviceInfo,
      ),
    );

    // if no data is send for 30 seconds, assume the transfer has crashed
    if (totalByteCountBefore == totalByteCount) {
      currentErrorTime = (currentErrorTime + (1000 / (1000 / duration.inMilliseconds))).toInt();
    } else {
      currentErrorTime = 0;
    }

    if (currentErrorTime > errorHandleTimeoutMilliseconds) {
      timer.cancel();
      dataToMainSendPort.send(ErrorReport(device: deviceInfo, message: "Transfer timed out"));
      receiverIsolate?.kill();
      Isolate.current.kill();
    }
    totalByteCountBefore = totalByteCount;
  });

  // Initialize receiver isolate

  ReceivePort receiverToDataPort = ReceivePort();

  receiverIsolate = await Isolate.spawn(_receiver, [
    receiverToDataPort.sendPort,
    files,
    deviceInfo,
    port,
  ]);

  receiverToDataPort.listen((message) {
    switch ((message).type) {
      case ConnectionActionType.start:
        totalByteCountBefore = 0;
        totalByteCount = 0;
        dataToMainSendPort.send(
          DataReport(
            files: files,
            filesTransferred: filesTransferred,
            currentFile: currentFile,
            speed: 0,
            progress: 0,
            deviceInfo: deviceInfo,
          ),
        );
        break;
      case ConnectionActionType.event:
        totalByteCount = message.totalTransferredBytes!;
        currentFile = message.currentFile!;
        break;
      case ConnectionActionType.fileEnd:
        filesTransferred.add(currentFile);
        dataToMainSendPort.send(
          FileEndReport(fileInfo: currentFile),
        );
        break;
      case ConnectionActionType.end:
        dataToMainSendPort.send(EndReport(device: deviceInfo, files: files, endTime: DateTime.now()));
        receiverIsolate?.kill();
        Isolate.current.kill();
        break;
      case ConnectionActionType.error:
        dataToMainSendPort.send(ErrorReport(device: deviceInfo, message: message.message));
        receiverIsolate?.kill();
        Isolate.current.kill();
        break;
    }
  });
}

void _receiver(List<dynamic> args) async {
  SendPort sendport = args[0];
  List<FileInfo> files = args[1];
  DeviceInfo senderDeviceInfo = args[2];
  int port = args[3];

  Future<void> receiveFile() async {
    RawSocket? socket;
    while (socket == null) {
      try {
        socket = await RawSocket.connect(senderDeviceInfo.ip, port);
      } catch (e) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    int totalRead = 0;

    File currentFile = File("${files.first.path!}.nocabtmp");
    if (currentFile.existsSync()) currentFile.deleteSync();
    await currentFile.create(recursive: true);

    IOSink currentSink = currentFile.openWrite(mode: FileMode.append);

    socket.write(utf8.encode(files.first.name));

    sendport.send(ConnectionAction(ConnectionActionType.start, currentFile: files.first));

    Uint8List? buffer;
    socket.listen((event) {
      switch (event) {
        case RawSocketEvent.read:
          buffer = socket?.read();
          if (buffer != null) {
            currentSink.add(buffer!);
            totalRead += buffer!.length;
            sendport.send(ConnectionAction(
              ConnectionActionType.event,
              currentFile: files.first,
              totalTransferredBytes: totalRead,
            ));
          }

          if (totalRead == files.first.byteSize) {
            socket?.close();
            sendport.send(ConnectionAction(ConnectionActionType.fileEnd, currentFile: files.first, totalTransferredBytes: totalRead));

            files.removeAt(0);
            if (files.isNotEmpty) {
              currentSink.close().then((value) => FileOperations.tmpToFile(currentFile));
              receiveFile();
            } else {
              currentSink.close().then((value) {
                return FileOperations.tmpToFile(currentFile).then((value) => sendport.send(ConnectionAction(ConnectionActionType.end)));
              });
            }
          }
          break;
        default:
          break;
      }
    });
  }

  receiveFile();
}
