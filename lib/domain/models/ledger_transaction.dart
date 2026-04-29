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
/// - [memo]: Transaction memo/description
/// - [entryDate]: Entry date (when transaction was entered)
/// - [commodity]: Commodity/currency code
/// - [extraAttributes]: Extra attributes as JSON string
/// - [extraInnerXml]: Extra inner XML content
class LedgerTransaction {
  final String id;
  final DateTime date;
  final List<Split> splits;
  final String memo;
  final String entryDate;
  final String commodity;
  final Map<String, String> extraAttributes;
  final String extraInnerXml;

  LedgerTransaction({
    required this.id,
    required this.date,
    required this.splits,
    required this.memo,
    required this.entryDate,
    required this.commodity,
    required this.extraAttributes,
    required this.extraInnerXml,
  });
}
