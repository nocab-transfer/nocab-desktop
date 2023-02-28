import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:nocab_core/nocab_core.dart';
import 'package:nocab_desktop/models/database/device_db.dart';
import 'package:nocab_desktop/models/database/file_db.dart';
import 'package:nocab_desktop/models/database/transfer_db.dart';
import 'package:nocab_desktop/services/database/converter.dart';
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
      isar.writeTxn(() async {
        for (var transfer in value) {
          transfer.status = TransferDbStatus.error;
          transfer.message = "Transfer interrupted";
          await isar.transferDatabases.put(transfer);
        }
      });
    });
  }

  Future<int> get getCount async => await isar.transferDatabases.count();

  static String getBasePath() {
    if (Platform.isWindows && !kDebugMode) {
      return p.join(Platform.environment['APPDATA']!, 'NoCab Desktop', 'database');
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
        .optional(
          ip != null,
          (q) => q.senderDevice((q) => q.deviceIpContains(ip!)).or().receiverDevice((q) => q.deviceIpContains(ip!)),
        )
        .optional(
          deviceName != null,
          (q) => q.senderDevice((q) => q.deviceNameContains(deviceName!)).or().receiverDevice((q) => q.deviceNameContains(deviceName!)),
        );

    return await query.findAll();
  }

  Future<bool> exist(String uuid) async => await isar.transferDatabases.where().filter().transferUuidEqualTo(uuid).findFirst() != null;

  Future<void> deleteAllTransfers() async {
    await isar.writeTxn(() async => await isar.transferDatabases.clear());
  }

  Future<void> registerRequest({
    required ShareRequest request,
    required DeviceInfo receiverDeviceInfo,
    required DeviceInfo senderDeviceInfo,
    required bool thisIsSender,
  }) async {
    var entry = TransferDatabase()
      ..senderDevice = senderDeviceInfo.toIsarDb(isCurrentDevice: thisIsSender)
      ..receiverDevice = receiverDeviceInfo.toIsarDb(isCurrentDevice: !thisIsSender)
      ..files = request.files.map((e) => e.toIsarDb()).toList()
      ..transferUuid = request.transferUuid
      ..requestedAt = DateTime.now()
      ..status = TransferDbStatus.pendingForAcceptance
      ..type = TransferDbType.upload
      ..managedBy = TransferDbManagedBy.user;

    await pushTransferToDb(entry);

    request.onResponse.then((value) {
      if (value.response) {
        linkTransferToEntry(request.linkedTransfer!, entry);
      } else {
        updateTransfer(request.transferUuid, status: TransferDbStatus.declined, message: value.info ?? 'Transfer was rejected');
      }
    });
  }

  Future<void> linkTransferToEntry(Transfer transfer, TransferDatabase entry) async {
    entry.files = transfer.files.map((e) => e.toIsarDb()).toList();
    transfer.onEvent.listen((report) {
      switch (report.runtimeType) {
        case StartReport:
          report as StartReport;
          entry.startedAt = report.startTime;
          entry.status = TransferDbStatus.ongoing;
          isar.writeTxn(() async => await isar.transferDatabases.put(entry));
          break;
        case EndReport:
          report as EndReport;
          entry.endedAt = report.endTime;
          entry.status = TransferDbStatus.success;
          isar.writeTxn(() async => await isar.transferDatabases.put(entry));
          break;
        case ErrorReport:
          report as ErrorReport;
          entry.endedAt = DateTime.now();
          entry.status = TransferDbStatus.error;
          entry.message = report.error.title;
          isar.writeTxn(() async => await isar.transferDatabases.put(entry));
          break;
        case CancelReport:
          report as CancelReport;
          entry.cancelledAt = DateTime.now();
          entry.status = TransferDbStatus.cancelled;
          isar.writeTxn(() async => await isar.transferDatabases.put(entry));
          break;
        default:
          break;
      }
    });
  }

  Future<int> getCountFiltered({
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
        .optional(
          ip != null,
          (q) => q.senderDevice((q) => q.deviceIpContains(ip!)).or().receiverDevice((q) => q.deviceIpContains(ip!)),
        )
        .optional(
          deviceName != null,
          (q) => q.senderDevice((q) => q.deviceNameContains(deviceName!)).or().receiverDevice((q) => q.deviceNameContains(deviceName!)),
        );

    return await query.count();
  }
}
