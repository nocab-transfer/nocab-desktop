import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:nocab_desktop/extensions/variables_from_base_deviceinfo.dart';
import 'package:nocab_desktop/models/settings_model.dart';
import 'package:nocab_desktop/services/network/network.dart';
import 'package:nocab_desktop/services/registry/registry.dart';
import 'package:path/path.dart' as p;

class SettingsService {
  static final SettingsService _singleton = SettingsService._internal();
  bool? isMsixInstalled;

  List<String> errors = [];

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
    try {
      File settingsFile = File(getdefaultSettingsPath());

      if (await settingsFile.exists()) {
        var settings = SettingsModel.fromJson(json.decode(await settingsFile.readAsString()));
        if (!(await Directory(settings.downloadPath).exists())) throw p.PathException("Download path does not exist\n${settings.downloadPath}");
        _settings = settings;
        return;
      }

      await settingsFile.create(recursive: true);
      _settings = await _createNewSettings();
      await settingsFile.writeAsString(json.encode(_settings?.toJson()));
    } catch (e) {
      _settings = await _createNewSettings();
      errors.add("$e\n\nUsing default options");
    }
  }

  Future<SettingsModel> _createNewSettings() async {
    return SettingsModel(
      deviceName: (await DeviceInfoPlugin().deviceInfo).deviceName,
      darkMode: RegistryService.isDarkMode(),
      useMaterial3: false,
      mainPort: await Network.getUnusedPort(),
      finderPort: 62193,
      language: Platform.localeName.split('_')[0],
      seedColor: RegistryService.getColor(),
      useSystemColor: Platform.isWindows,
      networkInterfaceName: Network.getCurrentNetworkInterface(await NetworkInterface.list()).name,
      downloadPath: Platform.isWindows ? p.join(Platform.environment['USERPROFILE']!, 'Downloads') : p.join(File(Platform.resolvedExecutable).parent.path, 'Output'),
    );
  }

  Future<void> recreateSettings() async {
    try {
      errors.clear();
      var settingsFile = File(getdefaultSettingsPath());
      if (await settingsFile.exists()) await settingsFile.delete();
      await initialize();
      _changeController.add(_settings!);
    } catch (e) {
      errors.add(e.toString());
      _changeController.add(_settings!);
    }
  }

  Future<bool> setSettings(SettingsModel settings) async {
    try {
      _settings = settings;
      _changeController.add(settings);
      File settingsFile = File(getdefaultSettingsPath());
      await settingsFile.writeAsString(json.encode(_settings?.toJson()));
      return true;
    } catch (e) {
      errors.add(e.toString());
      _changeController.add(_settings!);
      return false;
    }
  }

  String getdefaultSettingsPath() {
    if (Platform.isWindows && !kDebugMode) return p.join(Platform.environment['APPDATA']!, r'NoCab Desktop\settings.json');
    return p.join(File(Platform.resolvedExecutable).parent.path, "settings.json");
  }
}
