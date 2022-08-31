import 'dart:async';

import 'package:flutter/services.dart';
import 'package:nocab_desktop/l10n/generated/app_localizations.dart';
import 'package:nocab_desktop/models/settings_model.dart';
import 'package:nocab_desktop/provider/locale_provider.dart';
import 'package:nocab_desktop/provider/theme_provider.dart';
import 'package:nocab_desktop/screens/settings/setting_card.dart';
import 'package:flutter/material.dart';
import 'package:nocab_desktop/services/settings/settings.dart';
import 'package:provider/provider.dart';
import 'package:username_gen/username_gen.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  TextEditingController nameController = TextEditingController();
  late SettingsModel currentSettings;

  StreamSubscription? _settingsSubscription;

  @override
  void initState() {
    super.initState();
    currentSettings = SettingsService().getSettings;
    _settingsSubscription = SettingsService().onSettingChanged.listen((settings) => setState(() => currentSettings = settings));
    nameController.text = currentSettings.deviceName;
  }

  @override
  void dispose() {
    super.dispose();
    _settingsSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    //nameController.text = currentSettings.deviceName;

    return Dialog(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.centerLeft,
      backgroundColor: Colors.transparent,
      child: SizedBox(
        width: 550,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Stack(
                children: [
                  Center(child: Text(AppLocalizations.of(context)!.settingsTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24, fontWeight: FontWeight.w400))),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(8),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.close_rounded, size: 24),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: Container(
            width: 550,
            height: MediaQuery.of(context).size.height - 20,
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              borderRadius: const BorderRadius.all(Radius.circular(25)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height - 104,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SettingCard(
                              title: AppLocalizations.of(context)!.deviceNameSettingTitle,
                              caption: AppLocalizations.of(context)!.deviceNameSettingDescription,
                              widget: SizedBox(
                                width: 200,
                                height: 50,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 150,
                                      child: TextField(
                                        //scrollPadding: const EdgeInsets.all(0),
                                        controller: nameController,
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                                        onChanged: (String value) {
                                          if (value.isNotEmpty) {
                                            SettingsService().setSettings(currentSettings.copyWith(deviceName: value));
                                          } else {
                                            SettingsService().setSettings(currentSettings.copyWith(deviceName: "Unknown"));
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Material(
                                      child: Tooltip(
                                        triggerMode: TooltipTriggerMode.longPress,
                                        message: AppLocalizations.of(context)!.randomNameGenerateButtonTooltip,
                                        child: InkWell(
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                          onTap: () {
                                            String name = UsernameGen().generate();
                                            SettingsService().setSettings(currentSettings.copyWith(deviceName: name));
                                            nameController.text = name;
                                          },
                                          child: const SizedBox(
                                            width: 42,
                                            height: 42,
                                            child: Icon(Icons.refresh_rounded),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SettingCard(
                                title: AppLocalizations.of(context)!.themeColorSettingTitle,
                                caption: AppLocalizations.of(context)!.themeColorSettingDescription,
                                widget: Material(
                                  child: InkWell(
                                    onTap: () {
                                      Provider.of<ThemeProvider>(context, listen: false).toggleSeedColor();
                                      SettingsService().setSettings(currentSettings.copyWith(useSystemColor: !currentSettings.useSystemColor));
                                      SettingsService().setSettings(currentSettings.copyWith(seedColor: Provider.of<ThemeProvider>(context, listen: false).seedColor));
                                    },
                                    child: Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      child: Icon(Icons.ads_click_rounded, color: Theme.of(context).colorScheme.onPrimary),
                                    ),
                                  ),
                                )),
                            SettingCard(
                              title: AppLocalizations.of(context)!.darkModeSettingTitle,
                              caption: AppLocalizations.of(context)!.darkModeSettingDescription,
                              widget: Switch(
                                  value: currentSettings.darkMode,
                                  onChanged: (value) {
                                    SettingsService().setSettings(currentSettings.copyWith(darkMode: value));
                                    Provider.of<ThemeProvider>(context, listen: false).changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                                  },
                                  activeColor: Theme.of(context).colorScheme.primary),
                            ),
                            SettingCard(
                              title: AppLocalizations.of(context)!.startOnBootSettingTitle,
                              caption: AppLocalizations.of(context)!.startOnBootSettingDescription,
                              widget: Switch(
                                  value: currentSettings.startOnBoot,
                                  onChanged: (value) {
                                    SettingsService().setSettings(currentSettings.copyWith(startOnBoot: value));
                                  },
                                  activeColor: Theme.of(context).colorScheme.primary),
                            ),
                            SettingCard(
                              title: AppLocalizations.of(context)!.autoUpdateSettingTitle,
                              caption: AppLocalizations.of(context)!.autoUpdateSettingDescription,
                              widget: Switch(
                                  value: currentSettings.autoUpdate,
                                  onChanged: (value) {
                                    SettingsService().setSettings(currentSettings.copyWith(autoUpdate: value));
                                  },
                                  activeColor: Theme.of(context).colorScheme.primary),
                            ),
                            SettingCard(
                              title: AppLocalizations.of(context)!.languageSettingTitle,
                              caption: AppLocalizations.of(context)!.languageSettingDescription,
                              widget: SizedBox(
                                width: 100,
                                height: 50,
                                child: DropdownButtonFormField(
                                  value: Provider.of<LocaleProvider>(context).locale.languageCode,
                                  items: AppLocalizations.supportedLocales.map((Locale value) {
                                    return DropdownMenuItem<String>(
                                      value: value.languageCode,
                                      child: Text(value.languageCode),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      Provider.of<LocaleProvider>(context).setLocale(Locale(value));
                                      //FlutterI18n.refresh(Server().navigatorKey.currentContext!, Locale(value));
                                    }
                                  },
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                  iconEnabledColor: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            const Divider(),
                            Text(AppLocalizations.of(context)!.advancedSettingsTitle, style: Theme.of(context).textTheme.titleMedium),
                            Text(AppLocalizations.of(context)!.advancedSettingsDescription, textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            SettingCard(
                              title: AppLocalizations.of(context)!.finderPortSettingTitle,
                              caption: AppLocalizations.of(context)!.finderPortSettingDescription,
                              helpText: AppLocalizations.of(context)!.finderPortSettingHint,
                              widget: SizedBox(
                                width: 100,
                                height: 50,
                                child: TextField(
                                  onChanged: (String value) {
                                    if (value.isNotEmpty) {
                                      SettingsService().setSettings(currentSettings.copyWith(finderPort: int.parse(value)));
                                    } else {
                                      SettingsService().setSettings(currentSettings.copyWith(finderPort: 62193));
                                    }
                                  },
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                  ],
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    hintText: currentSettings.finderPort.toString(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
