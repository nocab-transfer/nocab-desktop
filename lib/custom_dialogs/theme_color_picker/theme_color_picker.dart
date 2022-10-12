import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nocab_desktop/models/settings_model.dart';
import 'package:nocab_desktop/provider/theme_provider.dart';
import 'package:nocab_desktop/screens/settings/setting_card.dart';
import 'package:nocab_desktop/services/settings/settings.dart';
import 'package:provider/provider.dart';

class ThemeColorPicker extends StatefulWidget {
  final Function(bool value)? onUseSystemColorChanged;
  final Function(Color color)? onColorClicked;
  const ThemeColorPicker({super.key, this.onUseSystemColorChanged, this.onColorClicked});

  @override
  State<ThemeColorPicker> createState() => ThemeColorPickerState();
}

class ThemeColorPickerState extends State<ThemeColorPicker> {
  StreamSubscription? _settingsSubscription;
  late SettingsModel currentSettings;

  @override
  void initState() {
    super.initState();
    currentSettings = SettingsService().getSettings;
    _settingsSubscription = SettingsService().onSettingChanged.listen((settings) => setState(() => currentSettings = settings));
  }

  @override
  void dispose() {
    _settingsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(64),
      alignment: Alignment.topRight,
      child: AnimatedContainer(
        width: 500,
        height: currentSettings.useSystemColor && Platform.isWindows ? 120 : 500,
        curve: Curves.ease,
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (Platform.isWindows) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SettingCard(
                  title: 'settings.themeColor.useSystemColor.title'.tr(),
                  caption: 'settings.themeColor.useSystemColor.description'.tr(),
                  widget: Switch(
                    value: currentSettings.useSystemColor,
                    onChanged: widget.onUseSystemColorChanged?.call,
                    activeColor: Theme.of(context).colorScheme.primary,
                    thumbIcon: switchIcon,
                  ),
                ),
              ),
            ],
            if (!currentSettings.useSystemColor || !Platform.isWindows) ...[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 70),
                        itemCount: Colors.accents.length,
                        itemBuilder: (context, index) {
                          var color = ThemeData(
                            colorSchemeSeed: Colors.accents[index],
                            useMaterial3: SettingsService().getSettings.useMaterial3,
                            brightness: Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light,
                          ).colorScheme.primary;
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: InkWell(
                              onTap: () => widget.onColorClicked?.call(Colors.accents[index]),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.ease,
                                decoration: BoxDecoration(
                                  color: color,
                                  boxShadow: Theme.of(context).colorScheme.primary == color ? [BoxShadow(color: Theme.of(context).colorScheme.primary, blurRadius: 5, spreadRadius: 1)] : null,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
