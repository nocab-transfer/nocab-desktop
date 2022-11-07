import 'package:nocab_desktop/models/deviceinfo_model.dart';
import 'package:nocab_desktop/services/transfer/report_models/base_report.dart';

class ErrorReport extends Report {
  DeviceInfo device;
  String message;

  ErrorReport({
    required this.device,
    required this.message,
  });
}
