import 'dart:async';

import 'package:flutter/material.dart';

class DurationIndicator extends StatefulWidget {
  final Duration duration;
  final double width;
  final Color color;
  const DurationIndicator({Key? key, required this.duration, required this.width, required this.color}) : super(key: key);

  @override
  State<DurationIndicator> createState() => _DurationIndicatorState();
}

class _DurationIndicatorState extends State<DurationIndicator> {
  late double width;
  @override
  void initState() {
    width = widget.width;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (width != 0) Timer(const Duration(milliseconds: 1), () => setState(() => width = 0));

    return AnimatedContainer(
      duration: widget.duration,
      curve: Curves.easeOutQuad,
      height: 2,
      width: width,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: const BorderRadius.all(Radius.circular(1)),
      ),
    );
  }
}
