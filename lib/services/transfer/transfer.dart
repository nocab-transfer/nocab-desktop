import 'dart:async';

import 'package:nocab_desktop/models/deviceinfo_model.dart';
import 'package:nocab_desktop/models/file_model.dart';
import 'package:nocab_desktop/services/transfer/report_models/base_report.dart';

abstract class Transfer {
  DeviceInfo deviceInfo;
  List<FileInfo> files;
  int transferPort;
  String uniqueId;
  bool ongoing = true;

  final eventController = StreamController<Report>.broadcast();
  Stream<Report> get onEvent => eventController.stream;

  Transfer({
    required this.deviceInfo,
    required this.files,
    required this.transferPort,
    required this.uniqueId,
  });

  Future<void> start();
}
