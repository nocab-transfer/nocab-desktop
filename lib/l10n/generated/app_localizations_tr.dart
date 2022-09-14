import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'NoCab Desktop';

  @override
  String get receiverTitle => 'Alıcı';

  @override
  String get senderTitle => 'Gönder';

  @override
  String get networkAdapterSettingsButtonTitle => 'Ağ bağdaştırıcı ayarları';

  @override
  String deviceShownAsLabelText(String deviceName) {
    return 'Cihaz ağda $deviceName olarak gözüküyor';
  }

  @override
  String get orLabelText => 'ya da';

  @override
  String get scanQrCodeLabelText => 'QR Kodunu Tara';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get filesLoadingLabelText => 'Dosyalar yükleniyor\nLütfen bekleyiniz...';

  @override
  String get chooseFilesButtonTitle => 'Dosyaları seç';

  @override
  String get dropFilesHereLabelText => 'ya da dosyaları buraya sürükleyin';

  @override
  String get transfersTitle => 'Transferler';

  @override
  String get openOutputFolderButtonTitle => 'Çıkış klasörünü aç';

  @override
  String get noTransferLabelText => 'Burada sessizlikten başka bir şey yok...';

  @override
  String get deviceNameSettingTitle => 'Cihaz adı';

  @override
  String get deviceNameSettingDescription => 'Diğer cihazların göreceği isim';

  @override
  String get randomNameGenerateButtonTooltip => 'Rastgele isim oluştur';

  @override
  String get themeColorSettingTitle => 'Tema rengi';

  @override
  String get themeColorSettingDescription => 'Uygulamanın rengini değiştir';

  @override
  String get themeColorUseSystemColorSettingTitle => 'Sistem Rengini Kullan';

  @override
  String get themeColorUseSystemColorSettingDescription => 'Uygulama rengi olarak sistem rengini kullan';

  @override
  String get darkModeSettingTitle => 'Karanlık mod';

  @override
  String get darkModeSettingDescription => 'Karanlık modu aç';

  @override
  String get useMaterialYouSettingTitle => 'Material 3 tasarımı kullan';

  @override
  String get useMaterialYouSettingDescription => 'Material You (Material 3) tasarımı kullan';

  @override
  String get languageSettingTitle => 'Dil';

  @override
  String get languageSettingDescription => 'Uygulamanın dilini değiştir';

  @override
  String get finderPortSettingTitle => 'Tarayıcı portu';

  @override
  String get finderPortSettingDescription => 'Port telefonunuz ile iletişim için kullanılacak.\nEğer cihazın yerel ağda görünmesini istemiyorsanız, 0 olarak ayarlayın.\nVarsayılan 62193';

  @override
  String get finderPortSettingHint => 'Bu ayar uygulamayı tekrar başlattığınızda etkin olacak';

  @override
  String get advancedSettingsTitle => 'Gelişmiş Ayarlar';

  @override
  String get advancedSettingsDescription => 'Bu ayarlar deneyimli kullanıcılar içindir. Eğer ne yaptığınızı bilmiyorsanız lütfen kurcalamayın.';

  @override
  String get filesTitle => 'Dosyalar';

  @override
  String filesLengthLabelText(num filesLenght, String filesSize) {
    return intl.Intl.pluralLogic(
      filesLenght,
      locale: localeName,
      one: '1 dosya - $filesSize',
      other: '$filesLenght dosya - $filesSize',
    );
  }

  @override
  String get devicesTitle => 'Cihazlar';

  @override
  String get showQrCodeButtonTitle => 'QR\'ı göster';

  @override
  String get emptyDeviceListLabelText => 'Cihaz bulunamadı';

  @override
  String get searchingDeviceLabelText => 'Cihazlar aranıyor...';

  @override
  String fileAccepterTitle(String deviceName, num filesLenght) {
    final String pluralString = intl.Intl.pluralLogic(
      filesLenght,
      locale: localeName,
      one: '$deviceName size bir dosya',
      other: '$deviceName size $filesLenght dosya',
    );

    return '$pluralString göndermek istiyor';
  }

  @override
  String fileAccepterInfoLabelText(String ip, String port) {
    return 'Ip: $ip - Port: $port';
  }

  @override
  String get acceptButtonTitle => 'Kabul et';

  @override
  String get rejectButtonTitle => 'Reddet';

  @override
  String get transferStartedLabelText => 'Transfer başladı \nCihazın bağlanması bekleniyor...';

  @override
  String get pendingLabelText => 'Bekliyor';

  @override
  String speedCounter(Object speed) {
    return '$speed MB/s';
  }

  @override
  String progressCounter(Object progress) {
    return '$progress%';
  }

  @override
  String get showInFolderButtonTitle => 'Klasörde göster';

  @override
  String get openButtonTitle => 'Aç';

  @override
  String get removeButtonTooltip => 'Kaldır';

  @override
  String senderCardSuccessLabelText(num filesLenght) {
    final String pluralString = intl.Intl.pluralLogic(
      filesLenght,
      locale: localeName,
      one: '1 dosya',
      other: '$filesLenght dosya',
    );

    return '$pluralString başarıyla gönderildi';
  }

  @override
  String receiverCardSuccessLabelText(num filesLenght) {
    final String pluralString = intl.Intl.pluralLogic(
      filesLenght,
      locale: localeName,
      one: '1 dosya',
      other: '$filesLenght dosya',
    );

    return '$pluralString başarıyla alındı';
  }

  @override
  String get transferErrorLabelText => 'Transfer Başarısız';
}
