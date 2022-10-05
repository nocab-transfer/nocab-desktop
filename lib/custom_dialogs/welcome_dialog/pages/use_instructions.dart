import 'package:flutter/material.dart';

class UseInstructions extends StatefulWidget {
  const UseInstructions({Key? key}) : super(key: key);

  @override
  State<UseInstructions> createState() => _UseInstructionsState();
}

class _UseInstructionsState extends State<UseInstructions> {
  var opacity = 0.0;

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
            Text("So how to use NoCab?", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            // same network
            Text("1- Make sure that both devices are connected to the same network.", style: Theme.of(context).textTheme.bodyLarge),
            Text("2- Open the app on both devices.", style: Theme.of(context).textTheme.bodyLarge),
            Text("3- Click on the send button on the device you want to send the file from.", style: Theme.of(context).textTheme.bodyLarge),
            Text("4- Click on the receive button on the device you want to receive the file.", style: Theme.of(context).textTheme.bodyLarge),
            Text("That's it! You can now send files between your devices.", style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
