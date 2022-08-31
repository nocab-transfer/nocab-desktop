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
      constraints: const BoxConstraints(minHeight: 100),
      //width: 50,
      //color: Colors.red,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: Theme.of(context).textTheme.headline6),
              SizedBox(
                width: 270,
                child: Text(caption ?? "", style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.w100), maxLines: 4),
              ),
              helpText != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.help_outline, color: Theme.of(context).colorScheme.onBackground, size: 16),
                          const SizedBox(width: 4),
                          Text(helpText ?? ""),
                        ],
                      ),
                    )
                  : Container(),
            ],
          ),
          widget,
        ]),
      ),
    );
  }
}
