import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseInitializer {
  static Future<void> initialize() async {
    // Required for desktop platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }
}
