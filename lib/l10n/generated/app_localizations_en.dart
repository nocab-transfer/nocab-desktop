import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'NoCab Desktop';

  @override
  String get receiverTitle => 'Receiver';

  @override
  String get senderTitle => 'Sender';

  @override
  String get networkAdapterSettingsButtonTitle => 'Network Adapter Settings';

  @override
  String deviceShownAsLabelText(String deviceName) {
    return 'Device Shown As\n${deviceName}';
  }

  @override
  String get orLabelText => 'or';

  @override
  String get scanQrCodeLabelText => 'Scan QR Code';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get filesLoadingLabelText => 'Files being loaded\nPlease wait...';

  @override
  String get chooseFilesButtonTitle => 'Choose Files';

  @override
  String get dropFilesHereLabelText => 'or drop files here';

  @override
  String get transfersTitle => 'Transfers';

  @override
  String get openOutputFolderButtonTitle => 'Open Output Folder';

  @override
  String get noTransferLabelText => 'There is nothing here except a great silence...';

  @override
  String get deviceNameSettingTitle => 'Device Name';

  @override
  String get deviceNameSettingDescription => 'The name of the device that will be shown to other devices.';

  @override
  String get randomNameGenerateButtonTooltip => 'Generate Random Name';

  @override
  String get themeColorSettingTitle => 'Theme Color';

  @override
  String get themeColorSettingDescription => 'Change the color of the application';

  @override
  String get themeColorUseSystemColorSettingTitle => 'Use System Color';

  @override
  String get themeColorUseSystemColorSettingDescription => 'Use the system color as the application color';

  @override
  String get darkModeSettingTitle => 'Dark Mode';

  @override
  String get darkModeSettingDescription => 'Open the dark mode';

  @override
  String get useMaterialYouSettingTitle => 'Use Material You Design';

  @override
  String get useMaterialYouSettingDescription => 'Use Material You (Material 3) Design';

  @override
  String get languageSettingTitle => 'Language';

  @override
  String get languageSettingDescription => 'Change the language of the application';

  @override
  String get finderPortSettingTitle => 'Finder Port';

  @override
  String get finderPortSettingDescription => 'The port will be use to communicate with phone.\nIf you want to device not to be found on the network, set the value to 0.\nDefault 62193';

  @override
  String get finderPortSettingHint => 'This will take effect next time you start the application';

  @override
  String get advancedSettingsTitle => 'Advanced Settings';

  @override
  String get advancedSettingsDescription => 'These options are for advanced users only. If you don\'t know what you are doing, don\'t touch them.';

  @override
  String get filesTitle => 'Files';

  @override
  String filesLengthLabelText(num filesLenght, String filesSize) {
    return intl.Intl.pluralLogic(
      filesLenght,
      locale: localeName,
      one: '1 file - $filesSize',
      other: '$filesLenght files - $filesSize',
    );
  }

  @override
  String get devicesTitle => 'Devices';

  @override
  String get showQrCodeButtonTitle => 'Show QR';

  @override
  String get emptyDeviceListLabelText => 'No devices found';

  @override
  String get searchingDeviceLabelText => 'Searching for devices...';

  @override
  String fileAccepterTitle(String deviceName, num filesLenght) {
    return intl.Intl.pluralLogic(
      filesLenght,
      locale: localeName,
      one: '$deviceName wants to send you a file',
      other: '$deviceName wants to send you $filesLenght files',
    );
  }

  @override
  String fileAccepterInfoLabelText(String ip, String port) {
    return 'Ip: $ip - Port: $port';
  }

  @override
  String get acceptButtonTitle => 'Accept';

  @override
  String get rejectButtonTitle => 'Reject';

  @override
  String get transferStartedLabelText => 'Transfer Started\nWaiting for device to connect...';

  @override
  String get pendingLabelText => 'Pending';

  @override
  String speedCounter(Object speed) {
    return '$speed MB/s';
  }

  @override
  String progressCounter(Object progress) {
    return '$progress%';
  }

  @override
  String get showInFolderButtonTitle => 'Show in Folder';

  @override
  String get openButtonTitle => 'Open';

  @override
  String get removeButtonTooltip => 'Remove';

  @override
  String senderCardSuccessLabelText(num filesLenght) {
    final String pluralString = intl.Intl.pluralLogic(
      filesLenght,
      locale: localeName,
      one: '1 file',
      other: '$filesLenght files',
    );

    return '$pluralString sent successfully';
  }

  @override
  String receiverCardSuccessLabelText(num filesLenght) {
    final String pluralString = intl.Intl.pluralLogic(
      filesLenght,
      locale: localeName,
      one: '1 file',
      other: '$filesLenght files',
    );

    return '$pluralString received successfully';
  }

  @override
  String get transferErrorLabelText => 'Transfer Failed';
}
