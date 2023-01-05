import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nocab_core/nocab_core.dart';
import 'package:nocab_desktop/custom_widgets/device_finder_bloc/device_finder_state.dart';
import 'package:nocab_desktop/services/settings/settings.dart';

class DeviceFinderCubit extends Cubit<DeviceFinderState> {
  DeviceFinderCubit() : super(const NoDevice());

  Timer? timer;

  Future<void> startScanning() async {
    timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (isClosed) timer?.cancel();
      Radar.searchForDevices(SettingsService().getSettings.finderPort).listen((event) {
        if (event.isNotEmpty && !isClosed) {
          emit(Found(event));
        } else if (!isClosed) {
          emit(const NoDevice());
        }
      });
    });
  }
}
