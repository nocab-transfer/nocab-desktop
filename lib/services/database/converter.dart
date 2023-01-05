import 'package:nocab_core/nocab_core.dart';
import 'package:nocab_desktop/models/database/device_db.dart';
import 'package:nocab_desktop/models/database/file_db.dart';

extension FileInfoToIsar on FileInfo {
  FileDb toIsarDb() {
    return FileDb()
      ..name = name
      ..byteSize = byteSize
      ..isEncrypted = isEncrypted
      ..hash = hash
      ..path = path;
  }
}

extension DeviceInfoToIsar on DeviceInfo {
  DeviceDb toIsarDb({bool isCurrentDevice = false}) {
    return DeviceDb()
      ..deviceName = name
      ..deviceIp = ip
      ..deviceOs = opsystem
      ..isCurrentDevice = isCurrentDevice;
  }
}

extension IsarDbToFileInfo on FileDb {
  FileInfo toFileInfo() {
    return FileInfo(name: name, byteSize: byteSize, isEncrypted: isEncrypted, hash: hash, path: path);
  }
}
