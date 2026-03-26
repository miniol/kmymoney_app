// Copyright (c) 2026 by Zafado.pl
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// Account Data Access Object
//
// Handles database operations for account data.
// Provides CRUD operations and balance calculations.

import 'package:sqflite/sqflite.dart';
import '../../domain/models/account.dart';
import 'app_database.dart';
import 'db_change_notifier.dart';
import '../../domain/models/money.dart';
import 'models/account_with_balance_row.dart';
import 'models/account_type.dart';

/// Data Access Object for account database operations.
///
/// This DAO provides methods for inserting, querying, and managing
/// account data in the SQLite database. It handles batch operations
/// for performance and notifies listeners of data changes.
///
/// Key features:
/// - Batch insertion for multiple accounts
/// - Balance calculation with transaction aggregation
/// - Filtering by account type and status
/// - Change notification for UI updates
class AccountDao {
  /// Inserts multiple accounts into the database.
  ///
  /// Uses batch operations for optimal performance when inserting
  /// many accounts at once. Replaces existing accounts with
  /// the same ID using conflict resolution.
  ///
  /// Parameters:
  /// - [accounts]: List of accounts to insert
  ///
  /// Notifies listeners of database changes after insertion.
  Future<void> insertAccounts(List<Account> accounts) async {
    // Get database instance for batch operation
    final db = await AppDatabase.instance.database;

    // Create batch for efficient multiple inserts
    final batch = db.batch();

    // Insert each account with proper type conversion
    for (final account in accounts) {
      batch.insert('accounts', {
        'id': account.id,
        'name': account.name,
        'type': account.type,
        'currency_id': account.currencyId,
        'closed': account.closed ? 1 : 0,
        'preferred': account.preferred ? 1 : 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Execute batch and notify listeners
    await batch.commit(noResult: true);
    // Notify that accounts have been updated
    DbChangeNotifier.instance.notify();
  }

  Future<List<Account>> getAccounts() async {
    final db = await AppDatabase.instance.database;

    final maps = await db.query('accounts');

    return maps.map((map) {
      return Account(
        id: map['id'] as String,
        name: map['name'] as String,
        type: map['type'] as String,
        currencyId: map['currency_id'] as String,
        closed: map['closed'] == '1',
        preferred: map['preferred'] == 1 || map['preferred'] == '1',
      );
    }).toList();
  }

  Future<void> clear() async {
    final db = await AppDatabase.instance.database;
    await db.delete('accounts');
    // notify that accounts have been updated
    DbChangeNotifier.instance.notify();
  }

  Future<List<AccountWithBalanceRow>> getAccountsWithBalances({
    required Set<AccountType> visibleTypes,
    required bool showClosed,
    required bool preferredOnly,
  }) async {
    final db = await AppDatabase.instance.database;

    final typeValues = visibleTypes.map((e) => "'${e.dbValue}'").join(',');

    final whereClosed = showClosed ? '' : 'AND a.closed = 0';

    final wherePreferred = preferredOnly ? 'AND a.preferred = 1' : '';

    final result = await db.rawQuery('''
    SELECT 
      a.id,
      a.name,
      a.type,
      a.currency_id,
      a.preferred,
      IFNULL(SUM(CAST(s.numerator AS INTEGER)), 0) as total_num,
      IFNULL(MAX(CAST(s.denominator AS INTEGER)), 1) as denom
    FROM accounts a
    LEFT JOIN splits s ON a.id = s.account_id
    WHERE a.type IN ($typeValues)
    $whereClosed
    $wherePreferred
    GROUP BY a.id
    ORDER BY a.name
    ''');
    return result.map((row) {
      return AccountWithBalanceRow(
        id: row['id'] as String,
        name: row['name'] as String,
        type: row['type'] as String,
        currencyId: row['currency_id'] as String,
        balance: Money(
          BigInt.parse(row['total_num'].toString()),
          BigInt.parse(row['denom'].toString()),
        ),
        isFavorite: row['preferred'] == 1 || row['preferred'] == '1',
      );
    }).toList();
  }
}
