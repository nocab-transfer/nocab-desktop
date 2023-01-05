import 'package:flutter/material.dart';
import 'package:animations/animations.dart' as a;

class DialogService {
  DialogService._();

  static final DialogService _singleton = DialogService._();

  factory DialogService() {
    return _singleton;
  }

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<T?> showModal<T>(WidgetBuilder builder, {bool dismissible = true}) async {
    while (navigatorKey.currentContext == null) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    return a.showModal(
      context: navigatorKey.currentContext!,
      builder: builder,
      configuration: a.FadeScaleTransitionConfiguration(barrierDismissible: dismissible),
    );
  }
}
