// Copyright (c) 2026 by Zafado.pl
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// Settings Provider
//
// Riverpod providers for application settings.
// Manages account filter settings state.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/models/account_filter_settings.dart';
import '../../data/database/models/account_type.dart';

/// Riverpod notifier for account filter settings.
///
/// This notifier manages the state of account filter settings
/// including visible account types, show closed accounts,
/// and preferred accounts only options. It provides methods
/// to toggle individual filter options.
///
/// State management:
/// - [AccountFilterSettings] holds current filter state
/// - Individual methods for toggling each filter option
/// - Immutable state updates with copyWith pattern
class AccountFilterNotifier extends StateNotifier<AccountFilterSettings> {
  /// Creates notifier with default filter settings.
  ///
  /// Initializes with [AccountFilterSettings.defaultSettings()]
  /// which provides sensible default filter values.
  AccountFilterNotifier() : super(AccountFilterSettings.defaultSettings());

  /// Toggles visibility of a specific account type.
  ///
  /// Adds or removes the account type from the visible types set.
  /// If the type is currently visible, it becomes hidden.
  /// If currently hidden, it becomes visible.
  ///
  /// Parameters:
  /// - [type]: Account type to toggle visibility for
  void toggleType(AccountType type) {
    // Create mutable copy of current visible types
    final current = Set<AccountType>.from(state.visibleTypes);

    // Toggle type visibility
    if (current.contains(type)) {
      current.remove(type);
    } else {
      current.add(type);
    }

    // Update state with new visible types
    state = state.copyWith(visibleTypes: current);
  }

  /// Toggles the "show closed accounts" filter option.
  ///
  /// When enabled, closed accounts are included in the
  /// account list. When disabled, they are hidden.
  void toggleShowClosed() {
    state = state.copyWith(showClosed: !state.showClosed);
  }

  /// Toggles the "preferred accounts only" filter option.
  ///
  /// When enabled, only accounts marked as preferred
  /// are shown in the account list.
  void togglePreferredOnly() {
    state = state.copyWith(preferredOnly: !state.preferredOnly);
  }
}

/// Riverpod provider for account filter settings.
///
/// This provider creates and manages an instance of
/// [AccountFilterNotifier] for use throughout the application.
/// Enables UI components to access and modify account
/// filtering preferences.
///
/// Usage:
/// ```dart
/// final settings = ref.watch(accountFilterProvider);
/// final notifier = ref.read(accountFilterProvider.notifier);
/// notifier.toggleType(AccountType.asset);
/// ```
///
/// Returns a [StateNotifierProvider] for filter settings.
final accountFilterProvider =
    StateNotifierProvider<AccountFilterNotifier, AccountFilterSettings>(
      (ref) => AccountFilterNotifier(),
    );
