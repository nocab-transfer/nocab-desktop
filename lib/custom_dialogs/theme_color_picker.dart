import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nocab_desktop/l10n/generated/app_localizations.dart';
import 'package:nocab_desktop/models/settings_model.dart';
import 'package:nocab_desktop/screens/settings/setting_card.dart';
import 'package:nocab_desktop/services/settings/settings.dart';

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
    return Dialog(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: AnimatedContainer(
        width: 500,
        height: currentSettings.useSystemColor ? 120 : 500,
        curve: Curves.ease,
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (Platform.isWindows) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SettingCard(
                  title: AppLocalizations.of(context).themeColorUseSystemColorSettingTitle,
                  caption: AppLocalizations.of(context).themeColorUseSystemColorSettingDescription,
                  widget: Switch(
                    value: currentSettings.useSystemColor,
                    onChanged: widget.onUseSystemColorChanged?.call,
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
            if (!currentSettings.useSystemColor) ...[
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
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: InkWell(
                              onTap: () => widget.onColorClicked?.call(Colors.accents[index]),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.accents[index],
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
