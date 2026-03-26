// Copyright (c) 2026
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// Account Domain Model
//
// Represents a financial account from KMyMoney data.
// Includes account metadata and status flags.

/// Represents a financial account from KMyMoney.
///
/// This domain model encapsulates account information including
/// identification, type, currency, and status flags. Accounts can be
/// bank accounts, credit cards, loans, or other financial containers.
///
/// Properties:
/// - [id]: Unique identifier from KMyMoney
/// - [name]: Human-readable account name
/// - [type]: Account type (e.g., 'CHECKING', 'SAVINGS', 'CREDIT')
/// - [currencyId]: Currency code for the account
/// - [closed]: Whether the account is closed/inactive
/// - [preferred]: Whether this is a preferred/favorite account
class Account {
  /// Unique identifier from KMyMoney system.
  final String id;

  /// Human-readable account name.
  final String name;

  /// Account type (e.g., 'CHECKING', 'SAVINGS', 'CREDIT').
  final String type;

  /// Currency code for the account (e.g., 'USD', 'EUR').
  final String currencyId;

  /// Whether the account is closed/inactive.
  final bool closed;

  /// Whether this is a preferred/favorite account.
  final bool preferred;

  /// Creates a new [Account] instance.
  ///
  /// Parameters:
  /// - [id]: Unique identifier (required)
  /// - [name]: Account name (required)
  /// - [type]: Account type (required)
  /// - [currencyId]: Currency identifier (required)
  /// - [closed]: Account status (required)
  /// - [preferred]: Whether account is preferred (defaults to false)
  Account({
    required this.id,
    required this.name,
    required this.type,
    required this.currencyId,
    required this.closed,
    this.preferred = false,
  });
}
