import 'package:device_info_plus/device_info_plus.dart';

extension DeviceInfoPluginExtension on BaseDeviceInfo {
  String get deviceName => this is WindowsDeviceInfo
      ? (this as WindowsDeviceInfo).computerName
      : this is MacOsDeviceInfo
          ? (this as MacOsDeviceInfo).computerName
          : this is LinuxDeviceInfo
              ? (this as LinuxDeviceInfo).prettyName
              : "Unknown";
}
