import 'package:nocab_desktop/models/deviceinfo_model.dart';
import 'package:nocab_desktop/models/file_model.dart';

abstract class Transfer {
  DeviceInfo deviceInfo;
  List<FileInfo> files;
  int transferPort;
  String uniqueId;

  Transfer({
    required this.deviceInfo,
    required this.files,
    required this.transferPort,
    required this.uniqueId,
  });

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
  });
}
