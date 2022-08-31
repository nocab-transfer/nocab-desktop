import 'package:nocab_desktop/models/deviceinfo_model.dart';
import 'package:nocab_desktop/models/file_model.dart';

enum DataReportType {
  start,
  info,
  end,
  error,
  fileEnd,
}

class DataReport {
  DataReportType type;

  List<FileInfo>? files;
  List<FileInfo>? filesTransferred;
  FileInfo? currentFile;
  double? speed;
  double? progress;
  DeviceInfo? deviceInfo;

  DataReport(
    this.type, {
    this.speed,
    this.progress,
    this.files,
    this.filesTransferred,
    this.currentFile,
    this.deviceInfo,
  });
}

enum ConnectionActionType {
  start,
  event,
  fileEnd,
  end,
  error,
}

class ConnectionAction {
  ConnectionActionType type;

  FileInfo? currentFile;
  int? totalTransferredBytes;

  ConnectionAction(this.type, {this.currentFile, this.totalTransferredBytes});
}
