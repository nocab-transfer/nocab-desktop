import 'package:animations/animations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nocab_desktop/custom_dialogs/loading_dialog/loading_dialog.dart';
import 'package:nocab_desktop/custom_dialogs/send_starter_dialog/send_starter_dialog.dart';
import 'package:nocab_desktop/l10n/generated/app_localizations.dart';
import 'package:nocab_desktop/models/file_model.dart';
import 'package:nocab_desktop/provider/locale_provider.dart';
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

  await IPC().initialize(args, onData: (data) async {
    // yeah i know this is bad but i dont know how to do it better
    while (Server().navigatorKey.currentContext == null) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    showDialog(
      context: Server().navigatorKey.currentContext!,
      builder: (context) => LoadingDialog(title: AppLocalizations.of(Server().navigatorKey.currentContext!).filesLoadingLabelText),
      barrierDismissible: false,
    );
    List<FileInfo> files = await FileOperations.convertPathsToFileInfos(data);
    Navigator.pop(Server().navigatorKey.currentContext!);
    showModal(
      context: Server().navigatorKey.currentContext!,
      configuration: const FadeScaleTransitionConfiguration(barrierDismissible: false),
      builder: ((context) => SendStarterDialog(files: files)),
    );
  });

  await SettingsService().initialize();
  await Server().initialize();
  await Server().startReceiver();
  await windowManager.ensureInitialized();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(
          themeMode: SettingsService().getSettings.darkMode ? ThemeMode.dark : ThemeMode.light,
          seedColor: SettingsService().getSettings.useSystemColor ? RegistryService.getColor() : SettingsService().getSettings.seedColor,
          useMaterial3: SettingsService().getSettings.useMaterial3,
        ),
      ),
      ChangeNotifierProvider(create: (_) => LocaleProvider(Locale(SettingsService().getSettings.language), AppLocalizations.supportedLocales)),
    ],
    child: const MyApp(),
  ));

  if (args.isNotEmpty) {
    // ugh this is kinda dirty
    while (Server().navigatorKey.currentContext == null) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    showDialog(
      context: Server().navigatorKey.currentContext!,
      builder: (context) => LoadingDialog(title: AppLocalizations.of(Server().navigatorKey.currentContext!).filesLoadingLabelText),
      barrierDismissible: false,
    );
    List<FileInfo> files = await FileOperations.convertPathsToFileInfos(args);
    Navigator.pop(Server().navigatorKey.currentContext!);
    showModal(
      context: Server().navigatorKey.currentContext!,
      configuration: const FadeScaleTransitionConfiguration(barrierDismissible: false),
      builder: ((context) => SendStarterDialog(files: files)),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NoCab Desktop',
      home: const MainScreen(),
      navigatorKey: Server().navigatorKey,
      themeMode: Provider.of<ThemeProvider>(context).themeMode,
      theme: ThemeData(colorSchemeSeed: Provider.of<ThemeProvider>(context).seedColor, brightness: Brightness.light, useMaterial3: Provider.of<ThemeProvider>(context).useMaterial3),
      darkTheme: ThemeData(colorSchemeSeed: Provider.of<ThemeProvider>(context).seedColor, brightness: Brightness.dark, useMaterial3: Provider.of<ThemeProvider>(context).useMaterial3),
      locale: Provider.of<LocaleProvider>(context).locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
