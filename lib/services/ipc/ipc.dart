import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:window_manager/window_manager.dart';

class IPC {
  static final IPC _singleton = IPC._internal();

  factory IPC() {
    return _singleton;
  }

  IPC._internal();

  Future<void> initialize(List<String> args,
      {Function(List<String> data)? onData}) async {
    if (Platform.isWindows) {
      if (await isNoCabAlreadyRunning()) {
        await connectToAnotherInstance(args);
        exit(0);
      } else {
        await watch(onData);
      }
    }
  }

  static Future<void> connectToAnotherInstance(List<String> args) async {
    var pidFolders =
        await Directory(getBasePath()).list(recursive: true).toList();
    for (var pidFolder in pidFolders
        .where((element) => Directory(element.path).existsSync())) {
      int runningPid = int.parse(p.basename(pidFolder.path));
      if (await isPidRunning(runningPid)) {
        var file =
            File(p.join(getBasePath(), runningPid.toString(), pid.toString()));
        IOSink sink = file.openWrite();
        sink.writeAll(args, "\n");
        await sink.close();
        exit(0);
      } else {
        await pidFolder.delete();
      }
    }
  }

  static Future<bool> isNoCabAlreadyRunning() async {
    if (!Platform.isWindows) throw Exception("This method is only for Windows");
    return await Process.run('tasklist', [
      '/nh',
      '/fo',
      'csv',
      '/fi',
      'imagename eq nocab_desktop.exe',
      '/fi',
      'PID ne $pid'
    ]).then((ProcessResult results) {
      if (results.stdout.toString().contains('nocab_desktop.exe')) return true;
      return false;
    });
  }

  static Future<bool> isPidRunning(int checkPid) async {
    if (!Platform.isWindows) throw Exception("This method is only for Windows");
    return await Process.run(
            'tasklist', ['/nh', '/fo', 'csv', '/fi', 'PID eq $checkPid'])
        .then((ProcessResult results) {
      if (results.stdout.toString().contains(checkPid.toString())) return true;
      return false;
    });
  }

  Future<void> watch(Function(List<String> args)? onData) async {
    Directory watchFile = Directory(p.join(getBasePath(), pid.toString()));
    if (await watchFile.parent.exists())
      await watchFile.parent.delete(recursive: true);
    await watchFile.create(recursive: true);
    watchFile.watch(events: FileSystemEvent.create).listen((event) async {
      while (await isPidRunning(int.parse(p.basename(event.path)))) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      File(event.path).readAsLines().then((value) {
        windowManager.focus();
        if (value.isNotEmpty) onData?.call(value);
        File(event.path).delete();
      });
    });
  }

  static String getBasePath() {
    if (Platform.isWindows)
      return p.join(Platform.environment['APPDATA']!, 'NoCab IPC');
    return p.join(File(Platform.resolvedExecutable).parent.path, 'NoCab IPC');
  }
}
