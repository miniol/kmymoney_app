// Copyright (c) 2026 by Zafado.pl
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// Payee Data Access Object
//
// Handles database operations for payee data.
// Provides CRUD operations for transaction recipients.

import 'package:sqflite/sqflite.dart';
import '../../domain/models/payee.dart';
import 'app_database.dart';
import 'db_change_notifier.dart';

/// Data Access Object for payee database operations.
///
/// This DAO provides methods for inserting, querying, and managing
/// payee data in SQLite database. Payees represent the
/// recipients or payers in financial transactions.
///
/// Key features:
/// - Batch insertion for multiple payees
/// - Conflict resolution with replace strategy
/// - Change notification for UI updates
class PayeeDao {
  /// Inserts multiple payees into the database.
  ///
  /// Uses batch operations for optimal performance when inserting
  /// many payees at once. Replaces existing payees with
  /// the same ID using conflict resolution.
  ///
  /// Parameters:
  /// - [payees]: List of payees to insert
  ///
  /// Notifies listeners of database changes after insertion.
  Future<void> insertPayees(List<Payee> payees) async {
    // Get database instance for batch operation
    final db = await AppDatabase.instance.database;

    // Create batch for efficient multiple inserts
    final batch = db.batch();

    // Insert each payee with conflict resolution
    for (final p in payees) {
      batch.insert('payees', {
        'id': p.id,
        'name': p.name,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Execute batch and notify listeners
    await batch.commit(noResult: true);
    DbChangeNotifier.instance.notify();
  }

  /// Clears all payees from the database.
  ///
  /// This method deletes all records from the payees table.
  /// Useful for data refresh or reset operations.
  ///
  /// Notifies listeners of database changes after clearing.
  Future<void> clear() async {
    // Get database instance and delete all payees
    final db = await AppDatabase.instance.database;
    await db.delete('payees');
    // Notify that payees have been cleared
    DbChangeNotifier.instance.notify();
  }
}
