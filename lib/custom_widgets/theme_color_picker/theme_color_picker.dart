import 'package:flutter/material.dart';

class ThemeColorPicker extends StatefulWidget {
  final Function(Color color, bool useSystemColor)? onColorPicked;
  const ThemeColorPicker({Key? key, this.onColorPicked}) : super(key: key);

  @override
  State<ThemeColorPicker> createState() => _ThemeColorPickerState();
}

class _ThemeColorPickerState extends State<ThemeColorPicker> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        onTap: () => widget.onColorPicked?.call(Colors.yellow, false),
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Icon(Icons.ads_click_rounded, color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
    );
  }
}
