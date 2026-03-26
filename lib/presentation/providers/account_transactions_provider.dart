import 'package:flutter_riverpod/flutter_riverpod.dart';
// Copyright (c) 2026 by Zafado.pl
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// Account Transactions Provider
//
// Riverpod provider for account-specific transactions.
// Provides real-time transaction data per account.

import '../../data/database/transaction_dao.dart';
import '../../data/database/db_change_notifier.dart';
import '../../domain/models/ledger_transaction.dart';

/// Riverpod family provider for account-specific transactions.
///
/// This provider creates a reactive stream of transactions for a
/// specific account ID. It automatically updates when the database
/// changes, ensuring real-time data synchronization.
///
/// Features:
/// - Family provider keyed by account ID
/// - Real-time database change monitoring
/// - Account-specific transaction filtering
/// - Automatic refresh on data changes
///
/// Parameters:
/// - [accountId]: Account ID to fetch transactions for
///
/// Returns stream of [LedgerTransaction] lists for the specified account.
final accountTransactionsProvider =
    StreamProvider.family<List<LedgerTransaction>, String>((
      ref,
      accountId,
    ) async* {
      // Get transaction DAO for database operations
      final dao = TransactionDao();

      // Emit initial transactions for the specified account
      yield await dao.getTransactionsForAccount(accountId);

      // Listen for database changes and refresh transactions
      await for (final _ in DbChangeNotifier.instance.stream) {
        yield await dao.getTransactionsForAccount(accountId);
      }
    });
