import 'package:nocab_desktop/models/deviceinfo_model.dart';
import 'package:nocab_desktop/models/file_model.dart';
import 'package:nocab_desktop/services/transfer/report_models/base_report.dart';

class DataReport extends Report {
  List<FileInfo> files;
  List<FileInfo> filesTransferred;
  FileInfo currentFile;
  double speed;
  double progress;
  DeviceInfo deviceInfo;

  DataReport({
    required this.files,
    required this.filesTransferred,
    required this.currentFile,
    required this.speed,
    required this.progress,
    required this.deviceInfo,
  });
}
