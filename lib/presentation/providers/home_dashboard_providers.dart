// Copyright (c) 2026 by Zafado.pl
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// Home Dashboard Providers
//
// Riverpod providers for dashboard data.
// Provides schedules and account summaries.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/account_dao.dart';
import '../../data/database/db_change_notifier.dart';
import '../../data/database/models/account_type.dart';
import '../../data/database/models/account_with_balance_row.dart';
import '../../data/database/models/schedule_with_details_row.dart';
import '../../data/database/schedule_dao.dart';

/// Riverpod provider for upcoming schedules on the dashboard.
///
/// This provider provides a reactive stream of the soonest
/// scheduled transactions (limited to 5 items) for display
/// on the home dashboard. Automatically updates when
/// database changes occur.
///
/// Features:
/// - Limited to 5 upcoming schedules
/// - Sorted by due date (soonest first)
/// - Real-time updates on database changes
/// - Optimized for dashboard display
final soonestSchedulesProvider = StreamProvider<List<ScheduleWithDetailsRow>>((
  ref,
) async* {
  // Get schedule DAO for database operations
  final dao = ScheduleDao();

  // Emit initial schedules (limited to 5)
  yield await dao.getSoonestSchedules(limit: 5);

  // Listen for database changes and refresh schedules
  await for (final _ in DbChangeNotifier.instance.stream) {
    yield await dao.getSoonestSchedules(limit: 5);
  }
});

/// Riverpod provider for preferred accounts on the dashboard.
///
/// This provider provides a reactive stream of preferred
/// accounts with their balances for display on the home
/// dashboard. Filters for preferred accounts and excludes
/// unknown account types.
///
/// Features:
/// - Only preferred accounts included
/// - Excludes unknown account types
/// - Includes balance calculations
/// - Real-time updates on database changes
final preferredAccountsProvider = StreamProvider<List<AccountWithBalanceRow>>((
  ref,
) async* {
  // Get account DAO for database operations
  final dao = AccountDao();

  // Define visible account types (exclude unknown)
  final visibleTypes = AccountType.values
      .where((t) => t != AccountType.unknown)
      .toSet();

  // Emit initial preferred accounts
  yield await dao.getAccountsWithBalances(
    visibleTypes: visibleTypes,
    showClosed: false,
    preferredOnly: true,
  );

  await for (final _ in DbChangeNotifier.instance.stream) {
    yield await dao.getAccountsWithBalances(
      visibleTypes: visibleTypes,
      showClosed: false,
      preferredOnly: true,
    );
  }
});
