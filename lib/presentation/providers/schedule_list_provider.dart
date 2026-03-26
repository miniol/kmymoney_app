// Copyright (c) 2026 by Zafado.pl
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// Schedule List Provider
//
// Riverpod provider for schedule list data.
// Provides real-time schedule updates.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/db_change_notifier.dart';
import '../../data/database/schedule_dao.dart';
import '../../data/database/models/schedule_with_details_row.dart';

/// Riverpod provider for complete schedule list.
///
/// This provider creates a reactive stream of all schedules
/// with their associated account and payee details. It
/// automatically updates when the database changes, ensuring
/// real-time data synchronization for the schedule list UI.
///
/// Features:
/// - Complete schedule list with joined details
/// - Real-time database change monitoring
/// - Automatic refresh on data changes
/// - Optimized for schedule list display
final scheduleListProvider = StreamProvider<List<ScheduleWithDetailsRow>>((
  ref,
) async* {
  // Get schedule DAO for database operations
  final dao = ScheduleDao();

  // Emit initial complete schedule list
  yield await dao.getSchedules();

  // Listen for database changes and refresh schedules
  await for (final _ in DbChangeNotifier.instance.stream) {
    yield await dao.getSchedules();
  }
});
