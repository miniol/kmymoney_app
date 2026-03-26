// Copyright (c) 2026 by Zafado.pl
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// Account List Provider
//
// Riverpod provider for account list data.
// Manages account filtering and real-time updates.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/account_dao.dart';
import '../../data/database/db_change_notifier.dart';
import '../../data/database/models/account_with_balance_row.dart';
// import '../../data/database/models/account_type.dart';
import 'settings_provider.dart';

/// Riverpod provider for filtered account list with balances.
///
/// This provider creates a reactive stream of accounts that
/// automatically updates when the database changes or filter
/// settings are modified. It combines data from multiple sources
/// to provide a filtered, real-time account list.
///
/// Features:
/// - Real-time database change monitoring
/// - Filter settings integration
/// - Balance calculation included
/// - Automatic refresh on data changes
final accountListProvider = StreamProvider<List<AccountWithBalanceRow>>((
  ref,
) async* {
  // Get account DAO instance
  final accountDao = AccountDao();

  // Stream filtered accounts with real-time updates
  yield* _watchAccounts(ref, accountDao);
});

/// Watches for account changes and provides filtered results.
///
/// This internal function creates a stream that:
/// 1. Emits initial filtered account list
/// 2. Listens for database change notifications
/// 3. Re-emits filtered data when changes occur
///
/// Parameters:
/// - [ref]: Riverpod ref for accessing other providers
/// - [accountDao]: DAO for account database operations
///
/// Returns stream of filtered [AccountWithBalanceRow] lists.
Stream<List<AccountWithBalanceRow>> _watchAccounts(
  Ref ref,
  AccountDao accountDao,
) async* {
  // Watch filter settings for real-time updates
  final settings = ref.watch(accountFilterProvider);

  // Emit initial filtered accounts
  yield await accountDao.getAccountsWithBalances(
    visibleTypes: settings.visibleTypes,
    showClosed: settings.showClosed,
    preferredOnly: settings.preferredOnly,
  );

  // Listen for database changes and re-emit data
  await for (final _ in DbChangeNotifier.instance.stream) {
    // Get updated filter settings
    final updatedSettings = ref.read(accountFilterProvider);

    yield await accountDao.getAccountsWithBalances(
      visibleTypes: updatedSettings.visibleTypes,
      showClosed: updatedSettings.showClosed,
      preferredOnly: updatedSettings.preferredOnly,
    );
  }
}
