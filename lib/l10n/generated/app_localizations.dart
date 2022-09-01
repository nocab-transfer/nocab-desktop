import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'NoCab Desktop'**
  String get appName;

  /// No description provided for @receiverTitle.
  ///
  /// In en, this message translates to:
  /// **'Receiver'**
  String get receiverTitle;

  /// No description provided for @senderTitle.
  ///
  /// In en, this message translates to:
  /// **'Sender'**
  String get senderTitle;

  /// No description provided for @networkAdapterSettingsButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Network Adapter Settings'**
  String get networkAdapterSettingsButtonTitle;

  /// No description provided for @deviceShownAsLabelText.
  ///
  /// In en, this message translates to:
  /// **'Device Shown As\n{device_name}'**
  String deviceShownAsLabelText(String device_name);

  /// No description provided for @orLabelText.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orLabelText;

  /// No description provided for @scanQrCodeLabelText.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQrCodeLabelText;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @filesLoadingLabelText.
  ///
  /// In en, this message translates to:
  /// **'Files being loaded\nPlease wait...'**
  String get filesLoadingLabelText;

  /// No description provided for @chooseFilesButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Files'**
  String get chooseFilesButtonTitle;

  /// No description provided for @dropFilesHereLabelText.
  ///
  /// In en, this message translates to:
  /// **'or drop files here'**
  String get dropFilesHereLabelText;

  /// No description provided for @transfersTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfers'**
  String get transfersTitle;

  /// No description provided for @openOutputFolderButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Open Output Folder'**
  String get openOutputFolderButtonTitle;

  /// No description provided for @noTransferLabelText.
  ///
  /// In en, this message translates to:
  /// **'There is nothing here except a great silence...'**
  String get noTransferLabelText;

  /// No description provided for @deviceNameSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Device Name'**
  String get deviceNameSettingTitle;

  /// No description provided for @deviceNameSettingDescription.
  ///
  /// In en, this message translates to:
  /// **'The name of the device that will be shown to other devices.'**
  String get deviceNameSettingDescription;

  /// No description provided for @randomNameGenerateButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Generate Random Name'**
  String get randomNameGenerateButtonTooltip;

  /// No description provided for @themeColorSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme Color'**
  String get themeColorSettingTitle;

  /// No description provided for @themeColorSettingDescription.
  ///
  /// In en, this message translates to:
  /// **'Change the color of the application'**
  String get themeColorSettingDescription;

  /// No description provided for @darkModeSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkModeSettingTitle;

  /// No description provided for @darkModeSettingDescription.
  ///
  /// In en, this message translates to:
  /// **'Open the dark mode'**
  String get darkModeSettingDescription;

  /// No description provided for @useMaterialYouSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Use Material You Design'**
  String get useMaterialYouSettingTitle;

  /// No description provided for @useMaterialYouSettingDescription.
  ///
  /// In en, this message translates to:
  /// **'Use Material You (Material 3) Design'**
  String get useMaterialYouSettingDescription;

  /// No description provided for @startOnBootSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Start On Boot'**
  String get startOnBootSettingTitle;

  /// No description provided for @startOnBootSettingDescription.
  ///
  /// In en, this message translates to:
  /// **'Start the application on boot'**
  String get startOnBootSettingDescription;

  /// No description provided for @autoUpdateSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto Update'**
  String get autoUpdateSettingTitle;

  /// No description provided for @autoUpdateSettingDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically update the application'**
  String get autoUpdateSettingDescription;

  /// No description provided for @languageSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSettingTitle;

  /// No description provided for @languageSettingDescription.
  ///
  /// In en, this message translates to:
  /// **'Change the language of the application'**
  String get languageSettingDescription;

  /// No description provided for @finderPortSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Finder Port'**
  String get finderPortSettingTitle;

  /// No description provided for @finderPortSettingDescription.
  ///
  /// In en, this message translates to:
  /// **'The port will be use to communicate with phone.\nIf you want to device not to be found on the network, set the value to 0.\nDefault 62193'**
  String get finderPortSettingDescription;

  /// No description provided for @finderPortSettingHint.
  ///
  /// In en, this message translates to:
  /// **'This will take effect next time you start the application'**
  String get finderPortSettingHint;

  /// No description provided for @advancedSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced Settings'**
  String get advancedSettingsTitle;

  /// No description provided for @advancedSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'These options are for advanced users only. If you don\'t know what you are doing, don\'t touch them.'**
  String get advancedSettingsDescription;

  /// No description provided for @filesTitle.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get filesTitle;

  /// No description provided for @filesLengthLabelText.
  ///
  /// In en, this message translates to:
  /// **'{files_lenght, plural, one{1 file - {files_size}} other{{files_lenght} files - {files_size}}}'**
  String filesLengthLabelText(num files_lenght, String files_size);

  /// No description provided for @showQrCodeButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Show QR'**
  String get showQrCodeButtonTitle;

  /// No description provided for @emptyDeviceListLabelText.
  ///
  /// In en, this message translates to:
  /// **'No devices found'**
  String get emptyDeviceListLabelText;

  /// No description provided for @searchingDeviceLabelText.
  ///
  /// In en, this message translates to:
  /// **'Searching for devices...'**
  String get searchingDeviceLabelText;

  /// No description provided for @fileAccepterTitle.
  ///
  /// In en, this message translates to:
  /// **'{device_name} wants to send you a {files_lenght, plural, one{file} other{{files_lenght} files}}'**
  String fileAccepterTitle(String device_name, num files_lenght);

  /// No description provided for @fileAccepterInfoLabelText.
  ///
  /// In en, this message translates to:
  /// **'Ip: {ip} - Port: {port}'**
  String fileAccepterInfoLabelText(String ip, String port);

  /// No description provided for @acceptButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptButtonTitle;

  /// No description provided for @rejectButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectButtonTitle;

  /// No description provided for @transferStartedLabelText.
  ///
  /// In en, this message translates to:
  /// **'Transfer Started\nWaiting for device to connect...'**
  String get transferStartedLabelText;

  /// No description provided for @pendingLabelText.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingLabelText;

  /// No description provided for @speedCounter.
  ///
  /// In en, this message translates to:
  /// **'{speed} MB/s'**
  String speedCounter(Object speed);

  /// No description provided for @progressCounter.
  ///
  /// In en, this message translates to:
  /// **'{progress}%'**
  String progressCounter(Object progress);

  /// No description provided for @showInFolderButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Show in Folder'**
  String get showInFolderButtonTitle;

  /// No description provided for @openButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openButtonTitle;

  /// No description provided for @removeButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeButtonTooltip;

  /// No description provided for @senderCardSuccessLabelText.
  ///
  /// In en, this message translates to:
  /// **'{files_lenght, plural, one{1 file} other{{files_lenght} files}} sent successfully'**
  String senderCardSuccessLabelText(num files_lenght);

  /// No description provided for @receiverCardSuccessLabelText.
  ///
  /// In en, this message translates to:
  /// **'{files_lenght, plural, one{1 file} other{{files_lenght} files}} received successfully'**
  String receiverCardSuccessLabelText(num files_lenght);

  /// No description provided for @transferErrorLabelText.
  ///
  /// In en, this message translates to:
  /// **'Transfer Failed'**
  String get transferErrorLabelText;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'tr': return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
