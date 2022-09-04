import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:nocab_desktop/extensions/variables_from_base_deviceinfo.dart';
import 'package:nocab_desktop/models/settings_model.dart';
import 'package:nocab_desktop/services/network/network.dart';
import 'package:nocab_desktop/services/registry/registry.dart';

class SettingsService {
  static final SettingsService _singleton = SettingsService._internal();

  factory SettingsService() {
    return _singleton;
  }

  SettingsService._internal();

  final _changeController = StreamController<SettingsModel>.broadcast();
  Stream<SettingsModel> get onSettingChanged => _changeController.stream;

  SettingsModel? _settings;
  SettingsModel get getSettings {
    if (_settings == null) throw Exception("Settings not initialized");
    return _settings!;
  }

  Future<void> initialize() async {
    File settingsFile = File("${File(Platform.resolvedExecutable).parent.path}${Platform.pathSeparator}settings.json");
    if (!settingsFile.existsSync()) {
      await settingsFile.create();
      _settings = await _createNewSettings();
      await settingsFile.writeAsString(json.encode(_settings?.toJson()));
    } else {
      _settings = SettingsModel.fromJson(json.decode(await settingsFile.readAsString()));
    }
  }

  Future<SettingsModel> _createNewSettings() async {
    return SettingsModel(
      deviceName: (await DeviceInfoPlugin().deviceInfo).deviceName,
      darkMode: RegistryService.isDarkMode(),
      useMaterial3: false,
      mainPort: 5001,
      finderPort: 62193,
      startOnBoot: false,
      autoUpdate: false,
      language: Platform.localeName.split('_')[0],
      seedColor: RegistryService.getColor(),
      useSystemColor: Platform.isWindows,
      networkInterfaceName: Network.getCurrentNetworkInterface(await NetworkInterface.list()).name,
    );
  }

  Future<void> setSettings(SettingsModel settings) async {
    _settings = settings;
    _changeController.add(settings);
    File settingsFile = File("${File(Platform.resolvedExecutable).parent.path}\\settings.json");
    await settingsFile.writeAsString(json.encode(_settings?.toJson()));
  }
}
