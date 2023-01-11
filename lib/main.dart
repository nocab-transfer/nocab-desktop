import 'package:easy_localization/easy_localization.dart';
import 'package:nocab_core/nocab_core.dart';
import 'package:nocab_desktop/custom_dialogs/loading_dialog/loading_dialog.dart';
import 'package:nocab_desktop/custom_dialogs/sender_dialog/sender_dialog.dart';
import 'package:nocab_desktop/custom_dialogs/welcome_dialog/welcome_dialog.dart';
import 'package:nocab_desktop/provider/theme_provider.dart';
import 'package:nocab_desktop/screens/main_screen/main_screen.dart';
import 'package:nocab_desktop/services/database/database.dart';
import 'package:nocab_desktop/services/dialog_service/dialog_service.dart';
import 'package:nocab_desktop/services/ipc/ipc.dart';
import 'package:nocab_desktop/services/network/network.dart';
import 'package:nocab_desktop/services/registry/registry.dart';
import 'package:flutter/material.dart';
import 'package:nocab_desktop/services/settings/settings.dart';
import 'package:nocab_desktop/services/transfer_manager/transfer_manager.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Network().initialize();
  var isFirstRun = await SettingsService().initialize();
  await IPC().initialize(args, onData: (data) async => _loadFiles(data));
  await Database().initialize();
  Radar().start();
  await TransferManager().initialize();
  await windowManager.ensureInitialized();

  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(
      themeMode: SettingsService().getSettings.darkMode ? ThemeMode.dark : ThemeMode.light,
      seedColor: SettingsService().getSettings.useSystemColor ? RegistryService.getColor() : SettingsService().getSettings.seedColor,
    ),
    child: EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('tr')],
      path: 'assets/i18n',
      fallbackLocale: const Locale('en'),
      saveLocale: false,
      useFallbackTranslations: true,
      useOnlyLangCode: true,
      child: const MyApp(),
    ),
  ));

  if (args.isNotEmpty && !isFirstRun) _loadFiles(args);
  if (isFirstRun) DialogService().showModal((context) => const WelcomeDialog(createdFromMain: true));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.setLocale(SettingsService().getSettings.locale);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NoCab Desktop',
      home: const MainScreen(),
      navigatorKey: DialogService.navigatorKey,
      themeMode: Provider.of<ThemeProvider>(context).themeMode,
      theme: ThemeData(colorSchemeSeed: Provider.of<ThemeProvider>(context).seedColor, brightness: Brightness.light, useMaterial3: true),
      darkTheme: ThemeData(colorSchemeSeed: Provider.of<ThemeProvider>(context).seedColor, brightness: Brightness.dark, useMaterial3: true),
      locale: context.locale,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
    );
  }
}

Future<void> _loadFiles(List<String> paths) async {
  BuildContext? dialogContext;
  DialogService().showModal((context) {
    dialogContext = context;
    return LoadingDialog(title: 'mainView.sender.loadingLabel'.tr());
  }, dismissible: false);
  List<FileInfo> files = await FileOperations.convertPathsToFileInfos(paths);
  Navigator.pop(dialogContext!);
  DialogService().showModal((context) => SendStarterDialog(files: files), dismissible: false);
}
