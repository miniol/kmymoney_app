// Copyright (c) 2026
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// KMyMoney File Provider
//
// Riverpod provider for KMyMoney file operations.
// Manages loading state and error handling.

import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../domain/repositories/kmy_repository.dart';
import 'repository_providers.dart';

/// Riverpod notifier for KMyMoney file operations.
///
/// This notifier manages the state of loading KMyMoney files,
/// providing loading states, success/error feedback, and
/// coordinating with the repository layer.
///
/// States:
/// - [AsyncLoading]: File loading in progress
/// - [AsyncData]: File loaded successfully
/// - [AsyncError]: Loading failed with error information
class KmyFileNotifier extends AsyncNotifier<void> {
  /// Initializes the notifier state.
  ///
  /// No initialization is required as the notifier starts
  /// in a neutral state ready for file operations.
  @override
  Future<void> build() async {
    // No initialization needed here
  }

  /// Loads a KMyMoney file from the specified path.
  ///
  /// This method handles the complete file loading workflow:
  /// 1. Sets loading state
  /// 2. Calls repository to load and parse file
  /// 3. Updates state with success or error
  ///
  /// Parameters:
  /// - [path]: File system path to KMyMoney file
  ///
  /// Emits loading, success, or error states accordingly.
  Future<void> loadFile(String path) async {
    // Set loading state to show progress indicator
    state = const AsyncLoading();

    try {
      // Get repository instance and load file
      final repository = ref.read(kmyRepositoryProvider);

      await repository.loadFromPath(path);

      // Set success state when loading completes
      state = const AsyncData(null);
    } catch (e, st) {
      // Set error state with exception details
      // Note: Consider using proper logging instead of print
      // print('ERROR: $e');
      // print(st);
      state = AsyncError(e, st);
    }
  }
}

/// Riverpod provider for KMyMoney file notifier.
///
/// Creates and provides an instance of [KmyFileNotifier]
/// for use throughout the application. This provider enables
/// the UI to respond to file loading states and operations.
///
/// Usage:
/// ```dart
/// final fileState = ref.watch(kmyFileProvider);
/// if (fileState.isLoading) { ... }
/// ```
final kmyFileProvider = AsyncNotifierProvider<KmyFileNotifier, void>(
  KmyFileNotifier.new,
);
