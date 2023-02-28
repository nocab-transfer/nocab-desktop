import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AlertBox extends StatelessWidget {
  final String title;
  final String message;
  final List<Widget> actions;
  const AlertBox({Key? key, required this.title, required this.message, required this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        height: 300,
        width: 400,
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 100, color: Colors.red)
                    .animate(onPlay: (controller) => controller.repeat())
                    .shakeX(duration: const Duration(seconds: 1))
                    .shake(duration: const Duration(seconds: 1))
                    .then(delay: 1.seconds),
                const SizedBox(height: 8),
                Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(message, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
                ),
                const SizedBox(height: 50),
                Container(),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
