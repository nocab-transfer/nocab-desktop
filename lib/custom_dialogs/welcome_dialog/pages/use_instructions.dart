import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class UseInstructions extends StatelessWidget {
  const UseInstructions({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> instructions = [
      "welcomeDialog.useInstructions.instructions.step1".tr(),
      "welcomeDialog.useInstructions.instructions.step2".tr(),
      "welcomeDialog.useInstructions.instructions.step3".tr(),
      "welcomeDialog.useInstructions.instructions.step4".tr(),
    ];

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("welcomeDialog.useInstructions.title".tr(), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          // same network
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: instructions.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Text("${index + 1}. ", style: Theme.of(context).textTheme.bodyLarge),
                  Expanded(child: Text(instructions[index], style: Theme.of(context).textTheme.bodyLarge)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text("welcomeDialog.useInstructions.hint".tr(), style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    ).animate(delay: 400.ms).fadeIn();
  }
}
