import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nocab_desktop/models/settings_model.dart';
import 'package:nocab_desktop/services/network/network.dart';
import 'package:nocab_desktop/services/registry/registry.dart';
import 'package:path/path.dart' as p;

class SettingsService {
  SettingsService._internal();
  static final SettingsService _singleton = SettingsService._internal();
  factory SettingsService() => _singleton;

  List<String> errors = [];

  final _changeController = StreamController<SettingsModel>.broadcast();
  Stream<SettingsModel> get onSettingChanged => _changeController.stream;

  SettingsModel? _settings;
  SettingsModel get getSettings {
    if (_settings == null) throw Exception("Settings not initialized");
    return _settings!;
  }

  NetworkInterface get getNetworkInterface =>
      Network.getNetworkInterfaceByName(getSettings.networkInterfaceName, Network().networkInterfaces) ??
      Network.getCurrentNetworkInterface(Network().networkInterfaces);

  // returns true if settings creatings for the first time
  Future<bool> initialize() async {
    try {
      File settingsFile = File(getdefaultSettingsPath());

      if (await settingsFile.exists()) {
        var settings = SettingsModel.fromJson(json.decode(await settingsFile.readAsString()));
        if (!(await Directory(settings.downloadPath).exists())) {
          throw p.PathException("Download path does not exist\n${settings.downloadPath}");
        }
        _settings = settings;
        return false;
      }

      await settingsFile.create(recursive: true);
      _settings = await _createNewSettings();
      await settingsFile.writeAsString(json.encode(_settings?.toJson()));
      return true;
    } catch (e) {
      _settings = await _createNewSettings();
      errors.add("$e\n\nUsing default options");
      return false;
    }
  }

  Future<SettingsModel> _createNewSettings() async {
    var rawLocale = Platform.localeName.split('.')[0];
    return SettingsModel(
      deviceName: Platform.localHostname,
      darkMode: RegistryService.isDarkMode(),
      mainPort: await Network.getUnusedPort(),
      finderPort: 62193,
      locale: rawLocale.contains('_') ? Locale(rawLocale.split('_')[0]) : Locale(rawLocale),
      seedColor: RegistryService.getColor(),
      useSystemColor: Platform.isWindows,
      networkInterfaceName: Network.getCurrentNetworkInterface(await NetworkInterface.list()).name,
      downloadPath: Platform.isWindows
          ? p.join(Platform.environment['USERPROFILE']!, 'Downloads')
          : p.join(File(Platform.resolvedExecutable).parent.path, 'Output'),
      dateFormatType: DateFormatType.base24,
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
    if (Platform.isWindows && !kDebugMode) {
      return p.join(Platform.environment['APPDATA']!, r'NoCab Desktop\settings.json');
    }
    return p.join(File(Platform.resolvedExecutable).parent.path, "settings.json");
  }
}
