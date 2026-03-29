// Copyright (c) 2026 by Zafado.pl
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// KMyMoney Local Path Provider
//
// Riverpod provider for managing local file path preferences.
// Persists KMyMoney file path using SharedPreferences.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Riverpod AsyncNotifier for managing local KMyMoney file path.
///
/// This provider handles persistent storage of the local KMyMoney file
/// path using SharedPreferences. It provides methods to get and set
/// the path with proper state management and loading states.
///
/// Features:
/// - Persistent storage using SharedPreferences
/// - Async state management with loading states
/// - Path validation and normalization
/// - Clear functionality to remove stored path
///
/// State management:
/// - Returns nullable String (null when no path is set)
/// - Provides AsyncLoading state during updates
/// - Normalizes paths by trimming whitespace
class KmyLocalPathProvider extends AsyncNotifier<String?> {
  /// SharedPreferences key for storing the local path.
  static const _key = 'kmy_local_path';

  /// Builds the initial state by loading stored path from SharedPreferences.
  ///
  /// Retrieves the stored KMyMoney file path from persistent storage.
  /// Returns null if no path is stored or if the stored value
  /// is empty or whitespace.
  ///
  /// Returns:
  /// - String containing the stored path, or
  /// - null if no valid path is stored
  @override
  Future<String?> build() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_key);
    return (v == null || v.trim().isEmpty) ? null : v;
  }

  /// Sets the local KMyMoney file path and persists it.
  ///
  /// Updates the stored path in SharedPreferences and triggers
  /// state update with loading state during the operation.
  /// Normalizes the path by trimming whitespace and handles
  /// null/empty values by removing the stored preference.
  ///
  /// Parameters:
  /// - [path]: The new path to store, or null to clear
  ///
  /// State changes:
  /// - Sets AsyncLoading during the operation
  /// - Updates to AsyncData with the new path
  Future<void> setPath(String? path) async {
    state = const AsyncLoading();

    final prefs = await SharedPreferences.getInstance();

    final normalized = (path == null || path.trim().isEmpty)
        ? null
        : path.trim();

    if (normalized == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, normalized);
    }

    state = AsyncData(normalized);
  }
}

/// Riverpod provider for KMyMoney local path management.
///
/// This provider creates and manages an instance of [KmyLocalPathNotifier]
/// for accessing and modifying the stored KMyMoney file path throughout
/// the application. It provides async state management with proper
/// loading states and error handling.
///
/// Usage:
/// ```dart
/// final path = ref.watch(kmyLocalPathProvider);
/// final notifier = ref.read(kmyLocalPathProvider.notifier);
/// await notifier.setPath('/path/to/file.kmy');
/// ```
///
/// Returns an [AsyncNotifierProvider] that manages nullable String state.
final kmyLocalPathProvider =
    AsyncNotifierProvider<KmyLocalPathProvider, String?>(
      KmyLocalPathProvider.new,
    );
