import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:nocab_desktop/models/database/device_db.dart';
import 'package:nocab_desktop/models/database/file_db.dart';

part 'transfer_db.g.dart';

@collection
@Name("Transfer")
class TransferDatabase {
  Id id = Isar.autoIncrement;

  @Name("Transfer Unique ID")
  late String transferUuid;

  @Name("Sender Device")
  late DeviceDb senderDevice;

  @Name("Receiver Device")
  late DeviceDb receiverDevice;

  @Name("Start Time")
  DateTime? startedAt;

  @Name("Requested At")
  late DateTime requestedAt;

  @Name("End Time")
  DateTime? endedAt;

  @Name("Cancelled At")
  DateTime? cancelledAt;

  @Name("Files")
  late List<FileDb> files;

  @enumerated
  @Name("Transfer Status")
  TransferDbStatus status = TransferDbStatus.ongoing;

  @enumerated
  @Name("Transfer Type")
  late TransferDbType type;

  @Name("Message")
  String? message;

  @Name("Managed By")
  @enumerated
  late TransferDbManagedBy managedBy;
}

enum TransferDbStatus {
  success,
  error,
  declined,
  ongoing,
  pendingForAcceptance,
  cancelled;
}

enum TransferDbType {
  download,
  upload,
}

enum TransferDbManagedBy {
  user,
  blacklist,
  ban,
  automation,
  thirdParty,
}

extension E1 on TransferDbStatus {
  Color get color {
    switch (this) {
      case TransferDbStatus.success:
        return Colors.green;
      case TransferDbStatus.error:
        return Colors.red;
      case TransferDbStatus.declined:
        return Colors.red;
      case TransferDbStatus.ongoing:
        return Colors.blue;
      case TransferDbStatus.pendingForAcceptance:
        return Colors.orange;
      case TransferDbStatus.cancelled:
        return Colors.red;
    }
  }
}

extension E2 on TransferDbType {
  IconData get icon {
    switch (this) {
      case TransferDbType.download:
        return Icons.download_rounded;
      case TransferDbType.upload:
        return Icons.upload_rounded;
    }
  }
}
