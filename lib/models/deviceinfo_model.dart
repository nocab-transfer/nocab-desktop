import 'package:nocab_desktop/models/database/device_db.dart';

class DeviceInfo {
  late String name;
  late String ip;
  late int port;
  late String opsystem;
  late String deviceId;

  DeviceInfo({required this.name, required this.ip, required this.port, required this.opsystem, required this.deviceId});

  DeviceInfo.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    ip = json['ip'];
    port = json['port'];
    opsystem = json['opsystem'];
    deviceId = json['deviceId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['ip'] = ip;
    data['port'] = port;
    data['opsystem'] = opsystem;
    data['deviceId'] = deviceId;
    return data;
  }

  DeviceDb toIsarDb({bool isCurrentDevice = false}) {
    return DeviceDb()
      ..deviceName = name
      ..deviceIp = ip
      ..deviceOs = opsystem
      ..isCurrentDevice = isCurrentDevice;
  }
}
