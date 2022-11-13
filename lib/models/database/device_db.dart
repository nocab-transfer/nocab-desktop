import 'package:isar/isar.dart';

part 'device_db.g.dart';

@embedded
class DeviceDb {
  @Name("Device Name")
  late String deviceName;

  @Name("Device IP")
  late String deviceIp;

  @Name("Device Port")
  late String deviceOs;

  @Name("Is Current Device")
  late bool isCurrentDevice;
}
