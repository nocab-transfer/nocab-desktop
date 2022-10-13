import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:nocab_desktop/models/deviceinfo_model.dart';
import 'package:nocab_desktop/models/file_model.dart';
import 'package:nocab_desktop/services/transfer/isolate_message.dart';
import 'package:nocab_desktop/services/transfer/transfer.dart';

class Sender extends Transfer {
  Sender({
    required DeviceInfo deviceInfo,
    required List<FileInfo> files,
    required int transferPort,
  }) : super(deviceInfo: deviceInfo, files: files, transferPort: transferPort);

  @override
  Future<void> start({
    Function(
      List<FileInfo> files,
      List<FileInfo> filesTransferred,
      FileInfo currentFile,
      double speed,
      double progress,
      DeviceInfo deviceInfo,
    )?
        onDataReport,
    Function(DeviceInfo serverDeviceInfo)? onStart,
    Function(DeviceInfo serverDeviceInfo, List<FileInfo> files)? onEnd,
    Function(FileInfo file)? onFileEnd,
    Function(DeviceInfo serverDeviceInfo, String message)? onError,
  }) async {
    ReceivePort dataToMainPort = ReceivePort();
    await Isolate.spawn(_dataHandler, [
      dataToMainPort.sendPort,
      files,
      deviceInfo,
      transferPort,
    ]);

    SendPort?
        mainToDataPort; // this will be used for pausing and resuming the transfer
    mainToDataPort;
    dataToMainPort.listen((message) {
      if (message is SendPort) mainToDataPort = message;

      if (message is DataReport) {
        switch (message.type) {
          case DataReportType.start:
            onStart?.call(message.deviceInfo!);
            break;
          case DataReportType.end:
            onEnd?.call(message.deviceInfo!, message.files!);
            break;
          case DataReportType.fileEnd:
            onFileEnd?.call(message.currentFile!);
            break;
          case DataReportType.info:
            onDataReport?.call(
              message.files!,
              message.filesTransferred!,
              message.currentFile!,
              message.speed!,
              message.progress!,
              message.deviceInfo!,
            );
            break;
          case DataReportType.error:
            onError?.call(message.deviceInfo!, "Crash");
            break;
        }
      }
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

  int totalByteCount = 0;
  int totalByteCountBefore = 0;
  const Duration duration = Duration(milliseconds: 100);

  const int errorHandleTimeoutMilliseconds = 30000;
  int currentErrorTime = 0;

  Timer.periodic(duration, (timer) {
    dataToMainSendPort.send(
      DataReport(
        DataReportType.info,
        files: files,
        filesTransferred: filesTransferred,
        currentFile: currentFile,
        speed: ((totalByteCount - totalByteCountBefore) *
                1000 /
                duration.inMilliseconds) /
            1024 /
            1024,
        progress: (100 * totalByteCount / currentFile.byteSize) > 100
            ? 100
            : (100 * totalByteCount / currentFile.byteSize),
        deviceInfo: deviceInfo,
      ),
    );

    // if no data is send for 30 seconds, assume the transfer has crashed
    if (totalByteCountBefore == totalByteCount) {
      currentErrorTime =
          (currentErrorTime + (1000 / (1000 / duration.inMilliseconds)))
              .toInt();
    } else {
      currentErrorTime = 0;
    }

    if (currentErrorTime > errorHandleTimeoutMilliseconds) {
      timer.cancel();
      dataToMainSendPort.send(DataReport(
        DataReportType.error,
        deviceInfo: deviceInfo,
      ));
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
            DataReportType.start,
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
          DataReport(
            DataReportType.info,
            files: files,
            filesTransferred: filesTransferred,
            currentFile: message.currentFile,
            speed: ((totalByteCount - totalByteCountBefore) *
                    1000 /
                    duration.inMilliseconds) /
                1024 /
                1024,
            progress: (100 * totalByteCount / currentFile.byteSize) > 100
                ? 100
                : (100 * totalByteCount / currentFile.byteSize),
            deviceInfo: deviceInfo,
          ),
        );
        filesTransferred.add(currentFile);
        break;
      case ConnectionActionType.end:
        dataToMainSendPort.send(DataReport(DataReportType.end,
            deviceInfo: deviceInfo, files: files));
        senderIsolate?.kill();
        Isolate.current.kill();
        break;
      case ConnectionActionType.error:
        dataToMainSendPort
            .send(DataReport(DataReportType.error, deviceInfo: deviceInfo));
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

  RawServerSocket server =
      await RawServerSocket.bind(InternetAddress.anyIPv4, port);

  Future<void> send(FileInfo fileInfo, RawSocket socket) async {
    try {
      final Uint8List buffer = Uint8List(1024 * 8);
      RandomAccessFile file = await File(fileInfo.path!).open();

      int bytesWritten = 0;
      int totalWrite = 0;

      int readBytesCountFromFile;
      while ((readBytesCountFromFile = file.readIntoSync(buffer)) > 0) {
        bytesWritten =
            socket.write(buffer.getRange(0, readBytesCountFromFile).toList());
        totalWrite += bytesWritten;
        file.setPositionSync(totalWrite);

        sendport.send(ConnectionAction(
          ConnectionActionType.event,
          currentFile: fileInfo,
          totalTransferredBytes: totalWrite,
        ));
      }
      sendport.send(ConnectionAction(ConnectionActionType.fileEnd,
          currentFile: fileInfo, totalTransferredBytes: totalWrite));
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
          sendport.send(
              ConnectionAction(ConnectionActionType.start, currentFile: file));
          send(file, socket);
          break;
        default:
          break;
      }
    });
  });
}
