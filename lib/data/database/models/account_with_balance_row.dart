// Copyright (c) 2026 by Zafado.pl
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// Account with Balance Row Model
//
// Database row model for accounts with calculated balances.
// Used in queries that need balance information.

import '../../../domain/models/money.dart';

/// Database row model representing an account with its calculated balance.
///
/// This model is used for database queries that need to include
/// account balance information alongside basic account details.
/// It's primarily used in UI components that display account lists
/// with balance information.
///
/// Properties:
/// - [id]: Account identifier
/// - [name]: Account display name
/// - [type]: Account type (asset, liability, etc.)
/// - [currencyId]: Currency code for the balance
/// - [balance]: Current account balance
/// - [isFavorite]: Whether account is marked as favorite
class AccountWithBalanceRow {
  /// Account identifier from database.
  final String id;

  /// Account display name.
  final String name;

  /// Account type classification.
  final String type;

  /// Currency code for the balance.
  final String currencyId;

  /// Current account balance.
  final Money balance;

  /// Whether account is marked as favorite.
  final bool isFavorite;

  /// Creates a new [AccountWithBalanceRow] instance.
  ///
  /// Parameters:
  /// - [id]: Account identifier (required)
  /// - [name]: Account name (required)
  /// - [type]: Account type (required)
  /// - [currencyId]: Currency code (required)
  /// - [balance]: Account balance (required)
  /// - [isFavorite]: Favorite status (defaults to false)
  AccountWithBalanceRow({
    required this.id,
    required this.name,
    required this.type,
    required this.currencyId,
    required this.balance,
    this.isFavorite = false,
  });
}
