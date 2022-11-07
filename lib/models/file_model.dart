import 'package:nocab_desktop/models/database/file_db.dart';
import 'package:nocab_desktop/models/deviceinfo_model.dart';

class ShareRequest {
  late List<FileInfo> files;
  late DeviceInfo deviceInfo;
  late int transferPort;
  String? transferUuid; // local

  ShareRequest({required this.files, required this.deviceInfo, required this.transferPort});

  ShareRequest.fromJson(Map<String, dynamic> json) {
    files = List<FileInfo>.from(json['files'].map((x) => FileInfo.fromJson(x)));
    deviceInfo = DeviceInfo.fromJson(json['deviceInfo']);
    transferPort = json['transferPort'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['files'] = List<dynamic>.from(files.map((x) => x.toJson()));
    map['deviceInfo'] = deviceInfo.toJson();
    map['transferPort'] = transferPort;
    return map;
  }
}

class FileInfo {
  late String name;
  late int byteSize;
  late bool isEncrypted;
  String? path; //local
  String? hash;
  String? subDirectory;

  FileInfo({required this.name, required this.byteSize, required this.isEncrypted, required this.hash, this.path, this.subDirectory});

  FileInfo.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    byteSize = json['byteSize'];
    isEncrypted = json['isEncrypted'];
    hash = json['hash'];
    subDirectory = json['subDirectory'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['byteSize'] = byteSize;
    data['isEncrypted'] = isEncrypted;
    data['hash'] = hash;
    data['subDirectory'] = subDirectory;
    return data;
  }

  static FileInfo empty() {
    return FileInfo(name: "File", byteSize: 1, isEncrypted: false, hash: "unused", path: null);
  }

  FileDb toIsarDb() {
    return FileDb()
      ..name = name
      ..byteSize = byteSize
      ..isEncrypted = isEncrypted
      ..hash = hash
      ..path = path;
  }
}

class ShareResponse {
  bool? response;
  String? info;

  ShareResponse({required this.response, this.info});

  ShareResponse.fromJson(Map<String, dynamic> json) {
    response = json['response'];
    info = json['info'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['response'] = response;
    map['info'] = info;
    return map;
  }
}
