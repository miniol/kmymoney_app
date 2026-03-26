// Copyright (c) 2026 by Zafado.pl
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// Transaction Data Access Object
//
// Handles database operations for transaction data.
// Provides CRUD operations for transactions and splits.

import 'package:sqflite/sqflite.dart';
import '../../domain/models/ledger_transaction.dart';
import '../../domain/models/split.dart';
import '../../domain/models/money.dart';
import 'app_database.dart';
import 'db_change_notifier.dart';

/// Data Access Object for transaction database operations.
///
/// This DAO provides methods for inserting, querying, and managing
/// transaction data and their associated splits in SQLite database.
/// Handles complex operations involving both transactions and splits.
///
/// Key features:
/// - Batch insertion for multiple transactions
/// - Atomic operations for transaction-split relationships
/// - Change notification for UI updates
class TransactionDao {
  /// Inserts multiple transactions with their splits into the database.
  ///
  /// This method performs atomic batch operations to ensure data
  /// consistency. Each transaction and all its splits are inserted
  /// together in a single batch operation.
  ///
  /// Parameters:
  /// - [transactions]: List of transactions to insert
  ///
  /// Notifies listeners of database changes after insertion.
  Future<void> insertTransactions(List<LedgerTransaction> transactions) async {
    // Get database instance for batch operation
    final db = await AppDatabase.instance.database;

    // Create batch for atomic operations
    final batch = db.batch();

    // Insert each transaction and its associated splits
    for (final tx in transactions) {
      // Insert transaction header
      batch.insert('transactions', {
        'id': tx.id,
        'post_date': tx.date.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      // Insert all splits for this transaction
      for (final split in tx.splits) {
        batch.insert('splits', {
          'transaction_id': tx.id,
          'account_id': split.accountId,
          'numerator': split.value.numerator.toString(),
          'denominator': split.value.denominator.toString(),
        });
      }
    }

    // Execute batch and notify listeners
    await batch.commit(noResult: true);
    // notify that transactions have been updated
    DbChangeNotifier.instance.notify();
  }

  Future<List<LedgerTransaction>> getTransactions() async {
    final db = await AppDatabase.instance.database;

    final txMaps = await db.query('transactions');

    final splitMaps = await db.query('splits');

    return txMaps.map((txMap) {
      final txId = txMap['id'] as String;

      final splits = splitMaps.where((s) => s['transaction_id'] == txId).map((
        s,
      ) {
        return Split(
          accountId: s['account_id'] as String,
          value: Money(
            BigInt.parse(s['numerator'] as String),
            BigInt.parse(s['denominator'] as String),
          ),
        );
      }).toList();

      return LedgerTransaction(
        id: txId,
        date: DateTime.parse(txMap['post_date'] as String),
        splits: splits,
      );
    }).toList();
  }

  Future<void> clear() async {
    final db = await AppDatabase.instance.database;
    await db.delete('splits');
    await db.delete('transactions');
    // notify that transactions have been updated
    DbChangeNotifier.instance.notify();
  }

  Future<List<LedgerTransaction>> getTransactionsForAccount(
    String accountId,
  ) async {
    final db = await AppDatabase.instance.database;

    final txMaps = await db.rawQuery(
      '''
    SELECT DISTINCT t.id, t.post_date
    FROM transactions t
    INNER JOIN splits s
      ON t.id = s.transaction_id
    WHERE s.account_id = ?
    ORDER BY t.post_date DESC
  ''',
      [accountId],
    );

    final splitMaps = await db.query(
      'splits',
      where: 'account_id = ?',
      whereArgs: [accountId],
    );

    return txMaps.map((txMap) {
      final txId = txMap['id'] as String;

      final splits = splitMaps.where((s) => s['transaction_id'] == txId).map((
        s,
      ) {
        return Split(
          accountId: s['account_id'] as String,
          value: Money(
            BigInt.parse(s['numerator'] as String),
            BigInt.parse(s['denominator'] as String),
          ),
        );
      }).toList();

      return LedgerTransaction(
        id: txId,
        date: DateTime.parse(txMap['post_date'] as String),
        splits: splits,
      );
    }).toList();
  }
}
