import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Text(FlutterI18n.translate(context, key), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),

                Text("Welcome to Nocab Desktop!", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 20),
                Text("Nocab Desktop is a file transfer application that allows you to transfer files between your devices without any server or third party service.\nIt is completely free and open source.", style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400)),
                const SizedBox(height: 20),
                Text("Click next button below!", style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: RichText(
                text: TextSpan(
                  text: 'Made with ',
                  children: [
                    WidgetSpan(child: InkWell(onTap: () => launchUrlString('https://flutter.dev/'), child: const FlutterLogo(size: 16))),
                    const TextSpan(text: ' Built with ❤️ by '),
                    WidgetSpan(
                      child: InkWell(
                        onTap: () => launchUrlString('https://github.com/berkekbgz'),
                        child: Text(
                          'berkekbgz',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.blue, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
