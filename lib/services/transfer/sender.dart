import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:nocab_desktop/models/deviceinfo_model.dart';
import 'package:nocab_desktop/models/file_model.dart';
import 'package:nocab_desktop/services/transfer/isolate_message.dart';
import 'package:nocab_desktop/services/transfer/report_models/base_report.dart';
import 'package:nocab_desktop/services/transfer/report_models/data_report.dart';
import 'package:nocab_desktop/services/transfer/report_models/end_report.dart';
import 'package:nocab_desktop/services/transfer/report_models/error_report.dart';
import 'package:nocab_desktop/services/transfer/report_models/fileend_report.dart';
import 'package:nocab_desktop/services/transfer/report_models/start_report.dart';
import 'package:nocab_desktop/services/transfer/transfer.dart';

class Sender extends Transfer {
  Sender({
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
    });
  }
}

Future<void> _dataHandler(List<dynamic> args) async {
  SendPort dataToMainSendPort = args[0];

  ReceivePort mainToDataPort = ReceivePort();
  dataToMainSendPort.send(mainToDataPort.sendPort);

  List<FileInfo> files = args[1];
  List<FileInfo> filesTransferred = [];
  FileInfo currentFile = files.first;

  DeviceInfo deviceInfo = args[2];

  final int port = args[3];

  Isolate? senderIsolate;

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
      dataToMainSendPort.send(ErrorReport(device: deviceInfo, message: 'Transfer timed out'));
      senderIsolate?.kill();
      Isolate.current.kill();
    }

    totalByteCountBefore = totalByteCount;
  });

  // Initialize sender isolate

  ReceivePort senderToDataPort = ReceivePort();

  senderIsolate = await Isolate.spawn(_sender, [
    senderToDataPort.sendPort,
    files,
    deviceInfo,
    port,
  ]);

  senderToDataPort.listen((message) {
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
        dataToMainSendPort.send(
          FileEndReport(fileInfo: currentFile),
        );
        filesTransferred.add(currentFile);
        break;
      case ConnectionActionType.end:
        dataToMainSendPort.send(EndReport(device: deviceInfo, files: files, endTime: DateTime.now()));
        senderIsolate?.kill();
        Isolate.current.kill();
        break;
      case ConnectionActionType.error:
        dataToMainSendPort.send(ErrorReport(device: deviceInfo, message: "Error: ${message.message}"));
        senderIsolate?.kill();
        Isolate.current.kill();
        break;
    }
  });
}

void _sender(List<dynamic> args) async {
  SendPort sendport = args[0];
  List<FileInfo> files = args[1];
  DeviceInfo receiverDeviceInfo = args[2];
  int port = args[3];

  RawServerSocket server = await RawServerSocket.bind(InternetAddress.anyIPv4, port);

  Future<void> send(FileInfo fileInfo, RawSocket socket) async {
    try {
      final Uint8List buffer = Uint8List(1024 * 8);
      RandomAccessFile file = await File(fileInfo.path!).open();

      int bytesWritten = 0;
      int totalWrite = 0;

      int readBytesCountFromFile;
      while ((readBytesCountFromFile = file.readIntoSync(buffer)) > 0) {
        bytesWritten = socket.write(buffer.getRange(0, readBytesCountFromFile).toList());
        totalWrite += bytesWritten;
        file.setPositionSync(totalWrite);

        sendport.send(ConnectionAction(
          ConnectionActionType.event,
          currentFile: fileInfo,
          totalTransferredBytes: totalWrite,
        ));
      }
      sendport.send(ConnectionAction(ConnectionActionType.fileEnd, currentFile: fileInfo, totalTransferredBytes: totalWrite));
      files.remove(fileInfo);
      if (files.isEmpty) {
        sendport.send(ConnectionAction(ConnectionActionType.end));
      }
    } catch (e) {
      socket.shutdown(SocketDirection.both);
      sendport.send(ConnectionAction(ConnectionActionType.error));
    }
  }

  server.listen((socket) {
    if (socket.remoteAddress.address != receiverDeviceInfo.ip) socket.close();

    socket.listen((event) {
      switch (event) {
        case RawSocketEvent.read:
          String data = utf8.decode(socket.read()!);
          FileInfo file = files.firstWhere((element) => element.name == data);
          sendport.send(ConnectionAction(ConnectionActionType.start, currentFile: file));
          send(file, socket);
          break;
        default:
          break;
      }
    });
  });
}
