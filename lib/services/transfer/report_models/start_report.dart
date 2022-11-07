import 'package:nocab_desktop/models/deviceinfo_model.dart';
import 'package:nocab_desktop/models/file_model.dart';
import 'package:nocab_desktop/services/transfer/report_models/base_report.dart';

class StartReport extends Report {
  DateTime startTime;
  DeviceInfo deviceInfo;
  List<FileInfo> files;

  StartReport({
    required this.startTime,
    required this.deviceInfo,
    required this.files,
  });
}
