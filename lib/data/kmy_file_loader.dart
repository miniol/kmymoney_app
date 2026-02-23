import 'dart:io';
import 'dart:convert';
import 'package:archive/archive.dart';

class KmyFileLoader {
  static Future<String> load(String path) async {
    final bytes = await File(path).readAsBytes();

    // GZIP magic header
    if (bytes[0] == 0x1F && bytes[1] == 0x8B) {
      final decompressed = GZipDecoder().decodeBytes(bytes);
      return utf8.decode(decompressed);
    }

    return utf8.decode(bytes);
  }
}
