import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';

class SettingsModel {
  late final String deviceName;
  late final int finderPort;
  late final int mainPort;
  late final bool darkMode;
  late final Color seedColor;
  late final bool useSystemColor;
  late final Locale locale;
  late final String networkInterfaceName;
  late String downloadPath;
  late DateFormatType dateFormatType;
  late bool hideSponsorSnackbar;

  SettingsModel({
    required this.deviceName,
    required this.finderPort,
    required this.mainPort,
    required this.darkMode,
    required this.locale,
    required this.seedColor,
    required this.useSystemColor,
    required this.networkInterfaceName,
    required this.downloadPath,
    required this.dateFormatType,
    required this.hideSponsorSnackbar,
  });

  SettingsModel.fromJson(Map<String, dynamic> json) {
    deviceName = json['deviceName'];
    finderPort = json['finderPort'];
    mainPort = json['mainPort'];
    darkMode = json['darkMode'];
    locale = Locale(json['language']);
    seedColor = Color(json['seedColor']);
    useSystemColor = json['useSystemColor'];
    networkInterfaceName = json['networkInterfaceName'];
    downloadPath = json['downloadPath'];
    dateFormatType = DateFormatType.getFromName(json['dateFormatType'] ?? DateFormatType.base24.name);
    hideSponsorSnackbar = json['hideSponsorSnackbar'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['deviceName'] = deviceName;
    data['finderPort'] = finderPort;
    data['mainPort'] = mainPort;
    data['darkMode'] = darkMode;
    data['language'] = locale.languageCode;
    data['seedColor'] = seedColor.value;
    data['useSystemColor'] = useSystemColor;
    data['networkInterfaceName'] = networkInterfaceName;
    data['downloadPath'] = downloadPath;
    data['dateFormatType'] = dateFormatType.name;
    data['hideSponsorSnackbar'] = hideSponsorSnackbar;
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
    String? networkInterfaceName,
    String? downloadPath,
    DateFormatType? dateFormatType,
    bool? hideSponsorSnackbar,
  }) {
    return SettingsModel(
      deviceName: deviceName ?? this.deviceName,
      finderPort: finderPort ?? this.finderPort,
      mainPort: mainPort ?? this.mainPort,
      darkMode: darkMode ?? this.darkMode,
      seedColor: seedColor ?? this.seedColor,
      useSystemColor: useSystemColor ?? this.useSystemColor,
      locale: Locale(language ?? locale.languageCode),
      networkInterfaceName: networkInterfaceName ?? this.networkInterfaceName,
      downloadPath: downloadPath ?? this.downloadPath,
      dateFormatType: dateFormatType ?? this.dateFormatType,
      hideSponsorSnackbar: hideSponsorSnackbar ?? this.hideSponsorSnackbar,
    );
  }
}

enum DateFormatType {
  base24("HH:mm dd/MM/yyyy"),
  base12("hh:mm a dd/MM/yyyy"),

  american("hh:mm a MM/dd/yyyy"),
  asian("HH:mm yyyy/MM/dd");

  const DateFormatType(this.stringFormat);
  final String stringFormat;

  DateFormat get dateFormat => DateFormat(stringFormat);

  static DateFormatType getFromName(String name) {
    return DateFormatType.values.firstWhere((element) => element.name == name, orElse: () => DateFormatType.values.first);
  }
}
