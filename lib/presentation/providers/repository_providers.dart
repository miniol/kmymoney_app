// Copyright (c) 2026 by Zafado.pl
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// Repository Providers
//
// Riverpod providers for dependency injection.
// Provides repository instances throughout the app.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/kmy_repository.dart';
import '../../data/repositories/kmy_repository_impl.dart';

/// Riverpod provider for KMyMoney repository.
///
/// This provider creates and manages the singleton instance
/// of [KmyRepositoryImpl] for dependency injection throughout
/// the application using Riverpod's provider pattern.
///
/// Usage:
/// ```dart
/// final repository = ref.read(kmyRepositoryProvider);
/// await repository.loadFromPath('/path/to/file.kmy');
/// ```
///
/// Returns a [KmyRepository] implementation instance.
final kmyRepositoryProvider = Provider<KmyRepository>((ref) {
  return KmyRepositoryImpl();
});
