// Copyright (c) 2026
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// Ledger Transaction Domain Model
//
// Represents a financial transaction with multiple splits.
// Follows double-entry accounting principles.

import 'split.dart';

/// Represents a financial transaction in the ledger.
///
/// This domain model follows double-entry accounting principles where
/// each transaction consists of one or more splits that balance
/// to zero. This ensures proper accounting of money flow.
///
/// Properties:
/// - [id]: Unique identifier from KMyMoney
/// - [date]: When the transaction occurred
/// - [splits]: List of account entries that balance to zero
class LedgerTransaction {
  /// Unique identifier from KMyMoney system.
  final String id;

  /// When the transaction occurred.
  final DateTime date;

  /// List of account entries that balance to zero.
  final List<Split> splits;

  /// Creates a new [LedgerTransaction] instance.
  ///
  /// All parameters are required for a complete transaction.
  ///
  /// Parameters:
  /// - [id]: Unique identifier
  /// - [date]: Transaction date
  /// - [splits]: List of balancing splits
  LedgerTransaction({
    required this.id,
    required this.date,
    required this.splits,
  });
}
