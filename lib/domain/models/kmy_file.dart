// Copyright (c) 2026
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// KMyMoney File Domain Model
//
// Represents a complete KMyMoney file with accounts and transactions.
// Serves as the top-level data container.

import 'account.dart';
import 'ledger_transaction.dart';

/// Represents a complete KMyMoney file.
///
/// This domain model serves as the top-level container for all
/// data parsed from a KMyMoney export file. It contains the
/// essential components needed for financial management.
///
/// Properties:
/// - [accounts]: List of all accounts in the file
/// - [transactions]: List of all transactions in the file
class KmyFile {
  /// List of all accounts in the KMyMoney file.
  final List<Account> accounts;

  /// List of all transactions in the KMyMoney file.
  final List<LedgerTransaction> transactions;

  /// Creates a new [KmyFile] instance.
  ///
  /// Parameters:
  /// - [accounts]: List of accounts (required)
  /// - [transactions]: List of transactions (required)
  KmyFile({required this.accounts, required this.transactions});
}
