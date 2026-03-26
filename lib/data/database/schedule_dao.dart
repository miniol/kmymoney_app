// Copyright (c) 2026 by Zafado.pl
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// Schedule Data Access Object
//
// Handles database operations for scheduled transaction data.
// Provides CRUD operations and complex queries.

import 'package:sqflite/sqflite.dart';
import '../../domain/models/money.dart';
import '../../domain/models/schedule.dart';
import 'app_database.dart';
import 'db_change_notifier.dart';
import 'models/schedule_with_details_row.dart';

/// Data Access Object for schedule database operations.
///
/// This DAO provides methods for inserting, querying, and managing
/// scheduled transaction data in SQLite database. Handles complex
/// queries with joins and aggregations for UI display.
///
/// Key features:
/// - Batch insertion for multiple schedules
/// - Complex queries with account/payee joins
/// - Date filtering and sorting
/// - Change notification for UI updates
class ScheduleDao {
  /// Inserts multiple schedules into the database.
  ///
  /// Uses batch operations for optimal performance when inserting
  /// many schedules at once. Converts domain models to
  /// database format with proper type conversions.
  ///
  /// Parameters:
  /// - [schedules]: List of schedules to insert
  ///
  /// Notifies listeners of database changes after insertion.
  Future<void> insertSchedules(List<Schedule> schedules) async {
    // Get database instance for batch operation
    final db = await AppDatabase.instance.database;

    // Create batch for efficient multiple inserts
    final batch = db.batch();

    // Insert each schedule with proper data conversion
    for (final s in schedules) {
      batch.insert('schedules', {
        'id': s.id,
        'group_key': s.group.dbValue,
        'name': s.name,
        'account_id': s.accountId,
        'currency_id': s.currencyId,
        'payee': s.payee,
        'frequency': s.frequency,
        'payment_method': s.paymentMethod,
        'next_due_date': s.nextDueDate.toIso8601String(),
        'amount_num': s.amount.numerator.toString(),
        'amount_denom': s.amount.denominator.toString(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Execute batch and notify listeners
    await batch.commit(noResult: true);
    DbChangeNotifier.instance.notify();
  }

  /// Clears all schedules from the database.
  ///
  /// This method deletes all records from the schedules table.
  /// Useful for data refresh or reset operations.
  ///
  /// Notifies listeners of database changes after clearing.
  Future<void> clear() async {
    // Get database instance and delete all schedules
    final db = await AppDatabase.instance.database;
    await db.delete('schedules');
    // Notify that schedules have been cleared
    DbChangeNotifier.instance.notify();
  }

  /// Retrieves all schedules with associated account and payee details.
  ///
  /// This complex query joins schedules with accounts and payees tables
  /// to provide complete information for UI display. Filters for
  /// schedules due today or in the future.
  ///
  /// Returns list of [ScheduleWithDetailsRow] objects sorted by due date.
  Future<List<ScheduleWithDetailsRow>> getSchedules() async {
    final db = await AppDatabase.instance.database;

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day).toIso8601String();

    final rows = await db.rawQuery(
      '''
      SELECT
        s.id,
        s.group_key,
        s.name,
        s.account_id,
        s.currency_id,
        IFNULL(p.name, s.payee) as payee,
        s.frequency,
        s.payment_method,
        s.next_due_date,
        s.amount_num,
        s.amount_denom,
        COALESCE(NULLIF(a.name, ''), NULLIF(TRIM(s.account_id), ''), '') as account_name,
        COALESCE(NULLIF(a.currency_id, ''), NULLIF(s.currency_id, ''), '') as account_currency_id
      FROM schedules s
      LEFT JOIN accounts a ON a.id = TRIM(s.account_id)
      LEFT JOIN payees p ON p.id = TRIM(s.payee)
      WHERE s.next_due_date >= ?
      ORDER BY s.next_due_date ASC
    ''',
      [todayStart],
    );

    return rows.map((r) {
      return ScheduleWithDetailsRow(
        id: r['id'] as String,
        group: ScheduleGroupX.fromString(r['group_key'] as String),
        name: r['name'] as String,
        accountName: r['account_name'] as String,
        currencyId: r['account_currency_id'] as String,
        amount: Money(
          BigInt.parse(r['amount_num'].toString()),
          BigInt.parse(r['amount_denom'].toString()),
        ),
        nextDueDate:
            DateTime.tryParse(r['next_due_date'] as String) ??
            DateTime(1970, 1, 1),
        payee: r['payee'] as String,
        frequency: r['frequency'] as String,
        paymentMethod: r['payment_method'] as String,
      );
    }).toList();
  }

  Future<List<ScheduleWithDetailsRow>> getSoonestSchedules({
    required int limit,
  }) async {
    final db = await AppDatabase.instance.database;

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day).toIso8601String();

    final rows = await db.rawQuery(
      '''
      SELECT
        s.id,
        s.group_key,
        s.name,
        s.account_id,
        s.currency_id,
        IFNULL(p.name, s.payee) as payee,
        s.frequency,
        s.payment_method,
        s.next_due_date,
        s.amount_num,
        s.amount_denom,
        COALESCE(NULLIF(a.name, ''), NULLIF(TRIM(s.account_id), ''), '') as account_name,
        COALESCE(NULLIF(a.currency_id, ''), NULLIF(s.currency_id, ''), '') as account_currency_id
      FROM schedules s
      LEFT JOIN accounts a ON a.id = TRIM(s.account_id)
      LEFT JOIN payees p ON p.id = TRIM(s.payee)
      WHERE s.next_due_date >= ?
      ORDER BY s.next_due_date ASC
      LIMIT ?
    ''',
      [todayStart, limit],
    );

    return rows.map((r) {
      return ScheduleWithDetailsRow(
        id: r['id'] as String,
        group: ScheduleGroupX.fromString(r['group_key'] as String),
        name: r['name'] as String,
        accountName: r['account_name'] as String,
        currencyId: r['account_currency_id'] as String,
        amount: Money(
          BigInt.parse(r['amount_num'].toString()),
          BigInt.parse(r['amount_denom'].toString()),
        ),
        nextDueDate:
            DateTime.tryParse(r['next_due_date'] as String) ??
            DateTime(1970, 1, 1),
        payee: r['payee'] as String,
        frequency: r['frequency'] as String,
        paymentMethod: r['payment_method'] as String,
      );
    }).toList();
  }
}
