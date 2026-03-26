// Copyright (c) 2026 by Zafado.pl
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// KMyMoney File Loader
//
// Handles loading and decompression of KMyMoney files.
// Supports both plan XML and GZIP-compressed formats.

import 'dart:io';
import 'dart:convert';
import 'package:archive/archive.dart';

/// Handles loading and decompression of KMyMoney files.
///
/// This utility class supports both plain XML files and GZIP-compressed
/// KMyMoney export files. It automatically detects the file format
/// and handles decompression as needed.
///
/// KMyMoney typically exports files in two formats:
/// - Plain XML (.kmy)
/// - GZIP-compressed XML (.kmy.gz)
///
/// Usage:
/// ```dart
/// final content = await KmyFileLoader.load('path/to/file.kmy');
/// final parser = KmyParser(content);
/// ```
class KmyFileLoader {
  /// Loads and reads a KMyMoney file from disk.
  ///
  /// Automatically detects whether the file is GZIP-compressed by checking
  /// for the GZIP magic header (0x1F 0x8B) and decompresses it if necessary.
  ///
  /// Parameters:
  /// - [path]: The file system path to the KMyMoney file
  ///
  /// Returns the file content as a UTF-8 decoded string.
  ///
  /// Throws [FileSystemException] if the file cannot be read.
  /// Throws [ArchiveException] if GZIP decompression fails.
  static Future<String> load(String path) async {
    final bytes = await File(path).readAsBytes();

    // Check for GZIP magic header (0x1F 0x8B)
    if (bytes.length >= 2 && bytes[0] == 0x1F && bytes[1] == 0x8B) {
      final decompressed = GZipDecoder().decodeBytes(bytes);
      return utf8.decode(decompressed);
    }

    // Return plain XML content as-is
    return utf8.decode(bytes);
  }
}
