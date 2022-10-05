import 'package:flutter/cupertino.dart';

class SettingsModel {
  late final String deviceName;
  late final int finderPort;
  late final int mainPort;
  late final bool darkMode;
  late final bool useMaterial3;
  late final Color seedColor;
  late final bool useSystemColor;
  late final Locale locale;
  late final String networkInterfaceName;
  late String downloadPath;

  SettingsModel({
    required this.deviceName,
    required this.finderPort,
    required this.mainPort,
    required this.darkMode,
    required this.useMaterial3,
    required this.locale,
    required this.seedColor,
    required this.useSystemColor,
    required this.networkInterfaceName,
    required this.downloadPath,
  });

  SettingsModel.fromJson(Map<String, dynamic> json) {
    deviceName = json['deviceName'];
    finderPort = json['finderPort'];
    mainPort = json['mainPort'];
    darkMode = json['darkMode'];
    useMaterial3 = json['useMaterial3'];
    locale = Locale(json['language'], json['country']);
    seedColor = Color(json['seedColor']);
    useSystemColor = json['useSystemColor'];
    networkInterfaceName = json['networkInterfaceName'];
    downloadPath = json['downloadPath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['deviceName'] = deviceName;
    data['finderPort'] = finderPort;
    data['mainPort'] = mainPort;
    data['darkMode'] = darkMode;
    data['useMaterial3'] = useMaterial3;
    data['language'] = locale.languageCode;
    data['country'] = locale.countryCode;
    data['seedColor'] = seedColor.value;
    data['useSystemColor'] = useSystemColor;
    data['networkInterfaceName'] = networkInterfaceName;
    data['downloadPath'] = downloadPath;
    return data;
  }
}

extension SettingsExtenios on SettingsModel {
  SettingsModel copyWith({
    String? deviceName,
    int? finderPort,
    int? mainPort,
    bool? darkMode,
    bool? useMaterial3,
    Color? seedColor,
    bool? useSystemColor,
    String? language,
    String? country,
    String? networkInterfaceName,
    String? downloadPath,
  }) {
    return SettingsModel(
      deviceName: deviceName ?? this.deviceName,
      finderPort: finderPort ?? this.finderPort,
      mainPort: mainPort ?? this.mainPort,
      darkMode: darkMode ?? this.darkMode,
      useMaterial3: useMaterial3 ?? this.useMaterial3,
      seedColor: seedColor ?? this.seedColor,
      useSystemColor: useSystemColor ?? this.useSystemColor,
      locale: Locale(language ?? locale.languageCode, country ?? locale.countryCode),
      networkInterfaceName: networkInterfaceName ?? this.networkInterfaceName,
      downloadPath: downloadPath ?? this.downloadPath,
    );
  }
}
