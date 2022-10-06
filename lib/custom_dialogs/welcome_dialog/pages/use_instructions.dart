import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class UseInstructions extends StatefulWidget {
  const UseInstructions({Key? key}) : super(key: key);

  @override
  State<UseInstructions> createState() => _UseInstructionsState();
}

class _UseInstructionsState extends State<UseInstructions> {
  var opacity = 0.0;
  final List<String> instructions = [
    "welcomeDialog.useInstructions.instructions.step1".tr(),
    "welcomeDialog.useInstructions.instructions.step2".tr(),
    "welcomeDialog.useInstructions.instructions.step3".tr(),
    "welcomeDialog.useInstructions.instructions.step4".tr(),
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          opacity = 1.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      opacity: opacity,
      child: Padding(
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
      ),
    );
  }
}
