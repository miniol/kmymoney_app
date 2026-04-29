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
import 'dart:convert';

/// Data Access Object for transaction database operations.
///
/// This DAO provides methods for inserting, querying, and managing
/// transaction data and their associated splits in SQLite database.
/// Handles complex operations involving both transactions and splits.
///
/// Note: This DAO uses batch operations for optimal performance when
/// inserting multiple transactions at once.
///
/// Key features:
/// - Batch insertion for multiple transactions
/// - Atomic operations for transaction-split relationships
/// - Change notification for UI updates
class TransactionDao {
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
        'memo': tx.memo,
        'entry_date': tx.entryDate,
        'commodity': tx.commodity,
        'extra_attrs_json': jsonEncode(tx.extraAttributes),
        'extra_inner_xml': tx.extraInnerXml,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      // Insert all splits for this transaction
      for (final split in tx.splits) {
        batch.insert('splits', {
          'transaction_id': tx.id,
          'split_id': split.id,
          'account_id': split.accountId,
          'value_num': split.value.numerator.toString(),
          'value_denom': split.value.denominator.toString(),
          'shares_num': split.shares.numerator.toString(),
          'shares_denom': split.shares.denominator.toString(),
          'price_num': split.price.numerator.toString(),
          'price_denom': split.price.denominator.toString(),
          'payee_id': split.payeeId,
          'reconcile_date': split.reconcileDate,
          'reconcile_flag': split.reconcileFlag,
          'action': split.action,
          'memo': split.memo,
          'number': split.number,
          'bankid': split.bankId,
          'extra_attrs_json': jsonEncode(split.extraAttributes),
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

      final txExtraAttrsRaw = (txMap['extra_attrs_json'] as String?) ?? '{}';
      final txExtraAttrsDecoded = (jsonDecode(txExtraAttrsRaw) as Map)
          .cast<String, String>();

      final splits = splitMaps.where((s) => s['transaction_id'] == txId).map((
        s,
      ) {
        final splitExtraAttrsRaw = (s['extra_attrs_json'] as String?) ?? '{}';
        final splitExtraAttrsDecoded = (jsonDecode(splitExtraAttrsRaw) as Map)
            .cast<String, String>();
        return Split(
          id: s['split_id'] as String,
          accountId: s['account_id'] as String,
          value: Money(
            BigInt.parse(s['value_num'] as String),
            BigInt.parse(s['value_denom'] as String),
          ),
          shares: Money(
            BigInt.parse(s['shares_num'] as String),
            BigInt.parse(s['shares_denom'] as String),
          ),
          price: Money(
            BigInt.parse(s['price_num'] as String),
            BigInt.parse(s['price_denom'] as String),
          ),
          payeeId: s['payee_id'] as String,
          reconcileDate: s['reconcile_date'] as String,
          reconcileFlag: s['reconcile_flag'] as String,
          action: s['action'] as String,
          memo: s['memo'] as String,
          number: s['number'] as String,
          bankId: s['bankid'] as String,
          extraAttributes: splitExtraAttrsDecoded,
        );
      }).toList();

      return LedgerTransaction(
        id: txId,
        date: DateTime.parse(txMap['post_date'] as String),
        splits: splits,
        memo: (txMap['memo'] as String?) ?? '',
        entryDate: (txMap['entry_date'] as String?) ?? '',
        commodity: (txMap['commodity'] as String?) ?? '',
        extraAttributes: txExtraAttrsDecoded,
        extraInnerXml: (txMap['extra_inner_xml'] as String?) ?? '',
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

    final txRows = await db.rawQuery(
      '''
      SELECT DISTINCT t.*
      FROM transactions t
      INNER JOIN splits s
        ON t.id = s.transaction_id
      WHERE s.account_id = ?
      ORDER BY t.post_date DESC
    ''',
      [accountId],
    );

    if (txRows.isEmpty) return [];

    final splitRows = await db.query(
      'splits',
      where: 'account_id = ?',
      whereArgs: [accountId],
      orderBy: 'row_id ASC',
    );

    return txRows.map((txMap) {
      final txId = txMap['id'] as String;

      final txExtraAttrsRaw = (txMap['extra_attrs_json'] as String?) ?? '{}';
      final txExtraAttrsDecoded = (jsonDecode(txExtraAttrsRaw) as Map)
          .cast<String, String>();

      final splits = splitRows.where((s) => s['transaction_id'] == txId).map((
        s,
      ) {
        final splitExtraAttrsRaw = (s['extra_attrs_json'] as String?) ?? '{}';
        final splitExtraAttrsDecoded = (jsonDecode(splitExtraAttrsRaw) as Map)
            .cast<String, String>();

        return Split(
          id: s['split_id'] as String,
          accountId: s['account_id'] as String,
          value: Money(
            BigInt.parse(s['value_num'] as String),
            BigInt.parse(s['value_denom'] as String),
          ),
          shares: Money(
            BigInt.parse(s['shares_num'] as String),
            BigInt.parse(s['shares_denom'] as String),
          ),
          price: Money(
            BigInt.parse(s['price_num'] as String),
            BigInt.parse(s['price_denom'] as String),
          ),
          payeeId: s['payee_id'] as String,
          reconcileDate: s['reconcile_date'] as String,
          reconcileFlag: s['reconcile_flag'] as String,
          action: s['action'] as String,
          memo: s['memo'] as String,
          number: s['number'] as String,
          bankId: s['bankid'] as String,
          extraAttributes: splitExtraAttrsDecoded,
        );
      }).toList();

      return LedgerTransaction(
        id: txId,
        date: DateTime.parse(txMap['post_date'] as String),
        splits: splits,
        memo: (txMap['memo'] as String?) ?? '',
        entryDate: (txMap['entry_date'] as String?) ?? '',
        commodity: (txMap['commodity'] as String?) ?? '',
        extraAttributes: txExtraAttrsDecoded,
        extraInnerXml: (txMap['extra_inner_xml'] as String?) ?? '',
      );
    }).toList();
  }
}
