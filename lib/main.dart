import 'package:animations/animations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nocab_desktop/custom_dialogs/loading_dialog/loading_dialog.dart';
import 'package:nocab_desktop/custom_dialogs/send_starter_dialog/send_starter_dialog.dart';
import 'package:nocab_desktop/custom_dialogs/welcome_dialog/welcome_dialog.dart';
import 'package:nocab_desktop/models/file_model.dart';
import 'package:nocab_desktop/provider/theme_provider.dart';
import 'package:nocab_desktop/screens/main_screen/main_screen.dart';
import 'package:nocab_desktop/services/file_operations/file_operations.dart';
import 'package:nocab_desktop/services/ipc/ipc.dart';
import 'package:nocab_desktop/services/registry/registry.dart';
import 'package:nocab_desktop/services/server/server.dart';
import 'package:flutter/material.dart';
import 'package:nocab_desktop/services/settings/settings.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  var isFirstTime = await SettingsService().initialize();
  await IPC().initialize(args, onData: (data) async => _loadFiles(data));
  await Server().initialize();
  await Server().startReceiver();
  await windowManager.ensureInitialized();

  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(
      themeMode: SettingsService().getSettings.darkMode ? ThemeMode.dark : ThemeMode.light,
      seedColor: SettingsService().getSettings.useSystemColor ? RegistryService.getColor() : SettingsService().getSettings.seedColor,
      useMaterial3: SettingsService().getSettings.useMaterial3,
    ),
    child: EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('tr', 'TR')],
      path: 'assets/i18n',
      fallbackLocale: const Locale('en', 'US'),
      saveLocale: false,
      useFallbackTranslations: true,
      child: const MyApp(),
    ),
  ));

  if (args.isNotEmpty && !isFirstTime) _loadFiles(args);
  if (isFirstTime) {
    while (Server().navigatorKey.currentContext == null) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    await showDialog(
      context: Server().navigatorKey.currentContext!,
      builder: (context) => const WelcomeDialog(createdFromMain: true),
    );
  }
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
      navigatorKey: Server().navigatorKey,
      themeMode: Provider.of<ThemeProvider>(context).themeMode,
      theme: ThemeData(colorSchemeSeed: Provider.of<ThemeProvider>(context).seedColor, brightness: Brightness.light, useMaterial3: Provider.of<ThemeProvider>(context).useMaterial3),
      darkTheme: ThemeData(colorSchemeSeed: Provider.of<ThemeProvider>(context).seedColor, brightness: Brightness.dark, useMaterial3: Provider.of<ThemeProvider>(context).useMaterial3),
      locale: context.locale,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
    );
  }
}

Future<void> _loadFiles(List<String> paths) async {
  // yeah i know this is bad but i dont know how to do it better
  while (Server().navigatorKey.currentContext == null) {
    await Future.delayed(const Duration(milliseconds: 100));
  }
  showDialog(
    context: Server().navigatorKey.currentContext!,
    builder: (context) => LoadingDialog(title: 'mainView.sender.loadingLabel'.tr()),
    barrierDismissible: false,
  );
  List<FileInfo> files = await FileOperations.convertPathsToFileInfos(paths);
  Navigator.pop(Server().navigatorKey.currentContext!);
  showModal(
    context: Server().navigatorKey.currentContext!,
    configuration: const FadeScaleTransitionConfiguration(barrierDismissible: false),
    builder: ((context) => SendStarterDialog(files: files)),
  );
}
