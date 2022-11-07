import 'package:isar/isar.dart';

part 'file_db.g.dart';

@embedded
class FileDb {
  @Name("File Name")
  late String name;

  @Name("File Size")
  late int byteSize;

  @Name("Encrypted")
  bool isEncrypted = false;

  @Name("File Path")
  String? path;

  @Name("File Hash")
  String? hash;
}
