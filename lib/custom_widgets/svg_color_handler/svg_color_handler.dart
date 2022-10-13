import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nocab_desktop/extensions/color_to_hex.dart';

class SvgColorHandler extends StatelessWidget {
  final String svgPath;
  final Map<Color, Color> colorSwitch;
  final double height;
  const SvgColorHandler(
      {Key? key,
      required this.svgPath,
      required this.colorSwitch,
      this.height = 150})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: DefaultAssetBundle.of(context).loadString(svgPath),
        builder: (context, snapshot) {
          return SvgPicture.string(
            colorSwitch.entries.fold(
              (snapshot.data ??
                  "<svg version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 1 1\"></svg>"),
              (String svg, e) => svg.replaceAll(
                  RegExp(e.key.toHex(), caseSensitive: false), e.value.toHex()),
            ),
            height: height,
          );
        });
  }
}
