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

///
/// Represents a single accounting entry within a transaction.
///
/// A split is the basic unit of double-entry accounting, representing
/// how money flows between accounts. Each transaction contains multiple
/// splits that balance to zero (debits equal credits).
///
/// Properties:
/// - [id]: Unique identifier from KMyMoney
/// - [accountId]: Which account is affected
/// - [value]: How much money (positive for credit, negative for debit)
/// - [shares]: Number of shares
/// - [price]: Price per share
/// - [payeeId]: Payee identifier
/// - [reconcileDate]: Reconciliation date
/// - [reconcileFlag]: Reconciliation flag
/// - [action]: Action taken
/// - [memo]: Memo/description
/// - [number]: Transaction number
/// - [bankId]: Bank identifier
/// - [extraAttributes]: Extra attributes as JSON string
///
class Split {
  final String id;
  final String accountId;
  final Money value;

  final Money shares;
  final Money price;

  final String payeeId;
  final String reconcileDate;
  final String reconcileFlag;
  final String action;
  final String memo;
  final String number;
  final String bankId;

  final Map<String, String> extraAttributes;

  Split({
    required this.id,
    required this.accountId,
    required this.value,
    required this.shares,
    required this.price,
    required this.payeeId,
    required this.reconcileDate,
    required this.reconcileFlag,
    required this.action,
    required this.memo,
    required this.number,
    required this.bankId,
    required this.extraAttributes,
  });
}
