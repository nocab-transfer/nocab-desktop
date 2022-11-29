import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nocab_desktop/custom_dialogs/update_dialog/update_dialog.dart';
import 'package:nocab_desktop/custom_widgets/custom_tooltip/custom_tooltip.dart';
import 'package:nocab_desktop/screens/settings/settings.dart';
import 'package:nocab_desktop/services/github/github.dart';

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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
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
                                .chain(CurveTween(curve: Curves.decelerate))
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
              FutureBuilder(
                future: Github().isUpdateAvailable(),
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: CustomTooltip(
                            message: 'update.tooltip'.tr(),
                            child: IconButton(
                              onPressed: () => showModal(context: context, builder: (context) => const UpdateDialog()),
                              style: IconButton.styleFrom(
                                fixedSize: const Size(30, 30),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0), side: BorderSide(color: Theme.of(context).colorScheme.primary)),
                              ),
                              icon: Icon(Icons.downloading_rounded, color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn()
                        .then(duration: 300.ms)
                        .animate(onComplete: (controller) => controller.repeat())
                        .shakeX(amount: 3)
                        .then(delay: 5.seconds);
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              )
            ],
          ),
        ),
      ],
    );
  }
}
