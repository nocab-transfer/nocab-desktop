import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nocab_desktop/screens/settings/settings.dart';

class SettingsPanel extends StatelessWidget {
  const SettingsPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text('mainView.settings.title'.tr(),
            style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Center(
          child: ElevatedButton(
            onPressed: () => showGeneralDialog(
              context: context,
              transitionDuration: const Duration(milliseconds: 200),
              barrierDismissible: true,
              barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
              pageBuilder: (context, animation, secondaryAnimation) => const Settings(),
              transitionBuilder: (context, animation, secondaryAnimation, child) {
                return BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: SlideTransition(
                        position: Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero)
                            .chain(CurveTween(curve: Curves.easeInOutCubic))
                            .animate(animation),
                        child: child));
              },
            ),
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(70, 70),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
            ),
            child: const Icon(Icons.settings_outlined),
          ),
        ),
      ],
    );
  }
}
