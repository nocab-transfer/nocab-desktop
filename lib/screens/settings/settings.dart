import 'dart:async';

import 'package:animations/animations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:nocab_desktop/custom_dialogs/theme_color_picker/theme_color_picker.dart';
import 'package:nocab_desktop/extensions/lang_code_to_name.dart';
import 'package:nocab_desktop/models/settings_model.dart';
import 'package:nocab_desktop/provider/theme_provider.dart';
import 'package:nocab_desktop/screens/settings/setting_card.dart';
import 'package:flutter/material.dart';
import 'package:nocab_desktop/services/github/github.dart';
import 'package:nocab_desktop/services/registry/registry.dart';
import 'package:nocab_desktop/services/settings/settings.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
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
    if (SettingsService().errors.isNotEmpty) return buildError();

    var switchIcon = MaterialStateProperty.resolveWith<Icon?>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return Icon(Icons.check_rounded, color: Theme.of(context).colorScheme.onPrimary);
        }
        return Icon(Icons.close_rounded, color: Theme.of(context).colorScheme.onInverseSurface);
      },
    );

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
            scrolledUnderElevation: 0,
            elevation: 0,
            flexibleSpace: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Material(
                        color: Colors.transparent,
                        child: OutlinedButton.icon(
                          onPressed: () => showModal(
                            context: context,
                            builder: _showAboutDialog,
                          ),
                          icon: const Icon(Icons.question_mark_rounded, size: 16),
                          label: Text('settings.aboutButton'.tr()),
                        ),
                      ),
                    ),
                  ),
                  Center(child: Text('settings.title'.tr(), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24, fontWeight: FontWeight.w400))),
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
              color: Theme.of(context).colorScheme.background,
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
                              title: 'settings.deviceName.title'.tr(),
                              caption: 'settings.deviceName.description'.tr(),
                              widget: SizedBox(
                                width: 200,
                                height: 70,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 150,
                                      child: TextField(
                                        controller: nameController,
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, counterText: ""),
                                        maxLength: 20,
                                        inputFormatters: [
                                          // block emojis
                                          FilteringTextInputFormatter.deny(RegExp(r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])')),
                                        ],
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
                                        message: 'settings.deviceName.randomNameTooltip'.tr(),
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
                              title: 'settings.themeColor.title'.tr(),
                              caption: 'settings.themeColor.description'.tr(),
                              widget: Material(
                                child: InkWell(
                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                  onTap: () {
                                    showModal(
                                      context: context,
                                      builder: (context) => ThemeColorPicker(
                                        onUseSystemColorChanged: (value) {
                                          SettingsService().setSettings(currentSettings.copyWith(useSystemColor: value));
                                          if (value) {
                                            Provider.of<ThemeProvider>(context, listen: false).changeSeedColor(RegistryService.getColor());
                                          } else {
                                            Provider.of<ThemeProvider>(context, listen: false).changeSeedColor(currentSettings.seedColor);
                                          }
                                        },
                                        onColorClicked: (color) {
                                          SettingsService().setSettings(currentSettings.copyWith(seedColor: color));
                                          Provider.of<ThemeProvider>(context, listen: false).changeSeedColor(color);
                                          //Navigator.pop(context);
                                        },
                                      ),
                                    );
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
                              ),
                            ),
                            SettingCard(
                              title: 'settings.darkMode.title'.tr(),
                              caption: 'settings.darkMode.description'.tr(),
                              widget: Switch(
                                  value: currentSettings.darkMode,
                                  thumbIcon: switchIcon,
                                  onChanged: (value) {
                                    SettingsService().setSettings(currentSettings.copyWith(darkMode: value));
                                    Provider.of<ThemeProvider>(context, listen: false).changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                                  },
                                  activeColor: Theme.of(context).colorScheme.primary),
                            ),
                            SettingCard(
                              title: 'settings.materialYou.title'.tr(),
                              caption: 'settings.materialYou.description'.tr(),
                              widget: Switch(
                                  value: currentSettings.useMaterial3,
                                  thumbIcon: switchIcon,
                                  onChanged: (value) {
                                    SettingsService().setSettings(currentSettings.copyWith(useMaterial3: value));
                                    Provider.of<ThemeProvider>(context, listen: false).materialYou(value: value);
                                  },
                                  activeColor: Theme.of(context).colorScheme.primary),
                            ),
                            SettingCard(
                              title: 'settings.language.title'.tr(),
                              caption: 'settings.language.description'.tr(),
                              widget: SizedBox(
                                width: 150,
                                height: 60,
                                child: DropdownButtonFormField(
                                  value: context.locale,
                                  items: context.supportedLocales.map((Locale value) {
                                    return DropdownMenuItem<Locale>(
                                      value: value,
                                      child: Text(value.langName),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      context.setLocale(value);
                                      SettingsService().setSettings(currentSettings.copyWith(language: value.languageCode));
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
                            Text('settings.advanced.title'.tr(), style: Theme.of(context).textTheme.titleMedium),
                            Text('settings.advanced.description'.tr(), textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            SettingCard(
                              title: 'settings.advanced.finderPort.title'.tr(),
                              caption: 'settings.advanced.finderPort.description'.tr(),
                              helpText: 'settings.advanced.finderPort.help'.tr(),
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

  Widget buildError() {
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
            scrolledUnderElevation: 0,
            elevation: 0,
            flexibleSpace: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Stack(
                children: [
                  Center(child: Text('settings.title'.tr(), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24, fontWeight: FontWeight.w400))),
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
              color: Theme.of(context).colorScheme.background,
              borderRadius: const BorderRadius.all(Radius.circular(25)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: Container(
                  height: 500,
                  width: 500,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: const BorderRadius.all(Radius.circular(25)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('Error', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.error)),
                            Text('Try recreate settings file or restart the application', style: Theme.of(context).textTheme.bodyLarge),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: OutlinedButton(
                                onPressed: () {
                                  SettingsService().recreateSettings();
                                },
                                child: const Text('Recreate settings file'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ListView.builder(
                                reverse: true,
                                itemCount: SettingsService().errors.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      height: 70,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.errorContainer.withOpacity(.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(SettingsService().errors[index], style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.error)),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _showAboutDialog(BuildContext context) {
    return AboutDialog(
      applicationIcon: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: const Image(
          image: AssetImage('assets/logo/logo.png'),
          height: 50,
          width: 50,
        ),
      ),
      applicationVersion: '1.0.0.0',
      children: [
        Center(
          child: TextButton(
            onPressed: () => launchUrlString('https://github.com/nocab-transfer'),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('aboutDialog.openGithubPage'.tr()),
            ),
          ),
        ),
        Text('aboutDialog.contributors'.tr(), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Container(
          height: 200,
          width: 350,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: const BorderRadius.all(Radius.circular(25)),
          ),
          child: FutureBuilder(
            future: Github.getContributors(owner: 'nocab-transfer', repo: 'nocab-desktop'),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'aboutDialog.errorMessage'.tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => launchUrlString(snapshot.data![index]['html_url']),
                        borderRadius: BorderRadius.circular(25),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(snapshot.data![index]['avatar_url']),
                          ),
                          title: Text(snapshot.data![index]['login']),
                          visualDensity: VisualDensity.compact,
                          trailing: const Icon(Icons.arrow_forward_ios_rounded),
                        ),
                      ),
                    );
                  },
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ],
    );
  }
}
