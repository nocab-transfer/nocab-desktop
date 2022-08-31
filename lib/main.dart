import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nocab_desktop/l10n/generated/app_localizations.dart';
import 'package:nocab_desktop/provider/locale_provider.dart';
import 'package:nocab_desktop/provider/theme_provider.dart';
import 'package:nocab_desktop/screens/main_screen/main_screen.dart';
import 'package:nocab_desktop/services/registry/registry.dart';
import 'package:nocab_desktop/services/server/server.dart';
import 'package:flutter/material.dart';
import 'package:nocab_desktop/services/settings/settings.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsService().initialize();

  if (args.isNotEmpty) {
    Future.delayed(
      const Duration(seconds: 2),
      () => Server().test(args),
    );
  }

  await Server().initialize();
  await Server().startReceiver();
  await windowManager.ensureInitialized();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(
          themeMode: SettingsService().getSettings.darkMode ? ThemeMode.dark : ThemeMode.light,
          seedColor: SettingsService().getSettings.useSystemColor ? RegistryService.getColor() : SettingsService().getSettings.seedColor,
        ),
      ),
      ChangeNotifierProvider(create: (_) => LocaleProvider(const Locale('en'), AppLocalizations.supportedLocales)),
    ],
    child: const MyApp(),
  ));

  windowManager.waitUntilReadyToShow(null, () async {
    await windowManager.show();
    await windowManager.focus();
  });
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
      theme: ThemeData(colorSchemeSeed: Provider.of<ThemeProvider>(context).seedColor, brightness: Brightness.light),
      darkTheme: ThemeData(colorSchemeSeed: Provider.of<ThemeProvider>(context).seedColor, brightness: Brightness.dark),
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
