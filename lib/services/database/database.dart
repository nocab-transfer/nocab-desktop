import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:nocab_desktop/models/database/device_db.dart';
import 'package:nocab_desktop/models/database/file_db.dart';
import 'package:nocab_desktop/models/database/transfer_db.dart';
import 'package:nocab_desktop/models/file_model.dart';
import 'package:nocab_desktop/services/transfer/report_models/base_report.dart';
import 'package:nocab_desktop/services/transfer/report_models/end_report.dart';
import 'package:nocab_desktop/services/transfer/report_models/error_report.dart';
import 'package:nocab_desktop/services/transfer/report_models/start_report.dart';
import 'package:path/path.dart' as p;

class Database {
  static final Database _singleton = Database._internal();

  factory Database() {
    return _singleton;
  }

  Database._internal();

  late Isar isar;

  Future<void> initialize() async {
    await Directory(getBasePath()).create();
    isar = await Isar.open([TransferDatabaseSchema], directory: getBasePath());

    // if pending or ongoing transfers exist, set them to failed
    await isar.transferDatabases
        .filter()
        .statusEqualTo(TransferDbStatus.pendingForAcceptance)
        .or()
        .statusEqualTo(TransferDbStatus.ongoing)
        .findAll()
        .then((value) async {
      for (var element in value) {
        await updateTransfer(element.transferUuid, status: TransferDbStatus.error, message: 'Transfer was interrupted');
      }
    });
  }

  Future<int> get getCount async => await isar.transferDatabases.count();

  static String getBasePath() {
    if (Platform.isWindows || kDebugMode) {
      return p.join(Platform.environment['APPDATA']!, 'database');
    }
    return p.join(File(Platform.resolvedExecutable).parent.path, 'database');
  }

  Future<void> pushTransferToDb(TransferDatabase transferDb) async {
    await isar.writeTxn(() async => await isar.transferDatabases.put(transferDb));
  }

  Future<void> updateTransfer(String transferUuid,
      {DateTime? startedAt,
      DateTime? endedAt,
      TransferDbStatus? status,
      List<FileInfo>? files,
      String? message,
      TransferDbManagedBy? managedBy}) async {
    var transferDb = await isar.transferDatabases.where().filter().transferUuidEqualTo(transferUuid).findFirst();
    if (transferDb == null) return;
    transferDb
      ..startedAt = startedAt ?? transferDb.startedAt
      ..endedAt = endedAt ?? transferDb.endedAt
      ..status = status ?? transferDb.status
      ..files = files?.map((e) => e.toIsarDb()).toList() ?? transferDb.files
      ..message = message ?? transferDb.message
      ..managedBy = managedBy ?? transferDb.managedBy;
    await isar.writeTxn(() async => await isar.transferDatabases.put(transferDb));
  }

  Future<List<TransferDatabase>> getTransfers({
    TransferDbStatus? status,
    DateTime? startedAt,
    DateTime? endedAt,
    String? contains,
    int? fileSize,
    String? ip,
    String? deviceName,
  }) async {
    var query = isar.transferDatabases
        .filter()
        .optional(status != null, (q) => q.statusEqualTo(status!))
        .optional(startedAt != null, (q) => q.startedAtGreaterThan(startedAt!))
        .optional(endedAt != null, (q) => q.endedAtLessThan(endedAt!))
        .optional(contains != null, (q) => q.filesElement((q) => q.nameContains(contains!)))
        .optional(fileSize != null, (q) => q.filesElement((q) => q.byteSizeGreaterThan(fileSize!)))
        .optional(ip != null, (q) => q.device((q) => q.deviceIpContains(ip!)))
        .optional(deviceName != null, (q) => q.device((q) => q.deviceNameContains(deviceName!)));

    return await query.findAll();
  }

  Future<void> updateTransferByReport(Report report) async {
    switch (report.runtimeType) {
      case StartReport:
        report as StartReport;
        Database().updateTransfer(
          report.transferUuid,
          status: TransferDbStatus.ongoing,
          files: report.files,
          startedAt: report.startTime,
        );
        break;
      case EndReport:
        report as EndReport;
        Database().updateTransfer(
          report.transferUuid,
          status: TransferDbStatus.success,
          endedAt: report.endTime,
        );
        break;
      case ErrorReport:
        report as ErrorReport;
        Database().updateTransfer(
          report.transferUuid,
          status: TransferDbStatus.error,
          message: report.message,
        );
        break;
      default:
    }
  }
}
