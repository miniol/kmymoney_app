// Copyright (c) 2026
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// Split Domain Model
//
// Represents a single accounting entry within a transaction.
// Associates an account with a monetary value.

import 'money.dart';

/// Represents a single accounting entry within a transaction.
///
/// A split is the basic unit of double-entry accounting, representing
/// how money flows between accounts. Each transaction contains multiple
/// splits that balance to zero (debits equal credits).
///
/// Properties:
/// - [accountId]: Which account is affected
/// - [value]: How much money (positive for credit, negative for debit)
class Split {
  /// Which account is affected by this split.
  final String accountId;

  /// Monetary value (positive for credit, negative for debit).
  final Money value;

  /// Creates a new [Split] instance.
  ///
  /// Parameters:
  /// - [accountId]: Account identifier (required)
  /// - [value]: Monetary value (required)
  Split({required this.accountId, required this.value});
}
