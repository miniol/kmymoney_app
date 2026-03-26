// Copyright (c) 2026
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// Database Initializer
//
// Initializes SQLite database support for desktop platforms.
// Required for Windows, Linux, and macOS when using sqflite.

import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Initializes SQLite database support for desktop platforms.
///
/// This utility class configures the SQLite database factory for
/// desktop platforms (Windows, Linux, macOS) which require the
/// sqflite_common_ffi package instead of the mobile SQLite implementation.
///
/// Must be called before any database operations are performed.
/// Typically called during app initialization in main().
class DatabaseInitializer {
  /// Initializes the database factory for desktop platforms.
  ///
  /// Configures sqfliteFfiInit() and databaseFactoryFfi for
  /// Windows, Linux, and macOS platforms. Mobile platforms (iOS/Android)
  /// use the default SQLite implementation and don't require this initialization.
  ///
  /// Should be called once during app startup before any database access.
  ///
  /// Throws [Exception] if initialization fails.
  static Future<void> initialize() async {
    // Configure SQLite for desktop platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }
}
