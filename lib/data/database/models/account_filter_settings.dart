// Copyright (c) 2026 by Zafado.pl
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// Account Filter Settings Model
//
// Immutable model for account filter preferences.
// Used for filtering account lists in the UI.

import 'account_type.dart';

/// Immutable model for account filter settings.
///
/// This class holds the filter preferences for displaying
/// accounts in the UI, including which account types to show,
/// whether to show closed accounts, and whether to show
/// only preferred accounts.
///
/// Properties:
/// - [visibleTypes]: Set of account types to display
/// - [showClosed]: Whether to include closed accounts
/// - [preferredOnly]: Whether to show only preferred accounts
class AccountFilterSettings {
  /// Set of account types that should be visible in the UI.
  final Set<AccountType> visibleTypes;

  /// Whether closed accounts should be included in the list.
  final bool showClosed;

  /// Whether only preferred accounts should be shown.
  final bool preferredOnly;

  /// Creates account filter settings with specified preferences.
  ///
  /// Parameters:
  /// - [visibleTypes]: Account types to display
  /// - [showClosed]: Include closed accounts flag
  /// - [preferredOnly]: Show only preferred accounts flag
  const AccountFilterSettings({
    required this.visibleTypes,
    required this.showClosed,
    required this.preferredOnly,
  });

  /// Creates default account filter settings.
  ///
  /// Returns sensible default filter settings that show
  /// assets and liabilities while hiding closed accounts
  /// and not filtering by preferred status.
  ///
  /// Returns default [AccountFilterSettings] instance.
  factory AccountFilterSettings.defaultSettings() {
    return const AccountFilterSettings(
      visibleTypes: {AccountType.asset, AccountType.liability},
      showClosed: false,
      preferredOnly: false,
    );
  }

  /// Creates a copy of this settings with updated values.
  ///
  /// Provides immutable state updates by creating a new
  /// instance with specified fields changed. Unspecified
  /// fields retain their original values.
  ///
  /// Parameters:
  /// - [visibleTypes]: New visible types set (optional)
  /// - [showClosed]: New show closed flag (optional)
  /// - [preferredOnly]: New preferred only flag (optional)
  ///
  /// Returns new [AccountFilterSettings] with updated values.
  AccountFilterSettings copyWith({
    Set<AccountType>? visibleTypes,
    bool? showClosed,
    bool? preferredOnly,
  }) {
    return AccountFilterSettings(
      visibleTypes: visibleTypes ?? this.visibleTypes,
      showClosed: showClosed ?? this.showClosed,
      preferredOnly: preferredOnly ?? this.preferredOnly,
    );
  }
}
