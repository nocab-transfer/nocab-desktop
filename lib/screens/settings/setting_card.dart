import 'package:flutter/material.dart';

class SettingCard extends StatelessWidget {
  final String title;
  final String? caption;
  final Widget widget;
  final String? helpText;
  const SettingCard({Key? key, required this.title, this.caption, required this.widget, this.helpText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 80),
      //width: 50,
      //color: Colors.red,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(title, style: Theme.of(context).textTheme.titleMedium),
                        Text(caption ?? "", style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w100), maxLines: 4),
                      ],
                    ),
                  ),
                ),
                widget,
              ]),
              if (helpText != null) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.help_outline, color: Theme.of(context).colorScheme.primary, size: 16),
                      const SizedBox(width: 4),
                      Text(helpText ?? "", style: Theme.of(context).textTheme.labelMedium)
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
