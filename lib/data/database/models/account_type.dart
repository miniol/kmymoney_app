// Copyright (c) 2026 by Zafado.pl
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// Account Type Enum
//
// Represents different types of financial accounts.
// Maps KMyMoney types to standardized values.

/// Represents different types of financial accounts.
///
/// This enum maps KMyMoney's numeric account type codes to
/// standardized, human-readable account categories. The mapping
/// follows standard accounting principles for asset classification.
///
/// Account types:
/// - [asset]: Cash, bank accounts, investments
/// - [liability]: Credit cards, loans, mortgages
/// - [income]: Salary, dividends, other income sources
/// - [expense]: Regular expenses, bills
/// - [equity]: Owner's equity, retained earnings
/// - [investment]: Investment accounts
/// - [unknown]: Unrecognized account types
enum AccountType {
  /// Asset accounts (cash, bank, investments)
  asset,

  /// Liability accounts (credit cards, loans)
  liability,

  /// Income accounts (salary, dividends)
  income,

  /// Expense accounts (bills, costs)
  expense,

  /// Equity accounts (owner's equity)
  equity,

  /// Investment accounts
  investment,

  /// Unknown/unrecognized account type
  unknown,
}

/// Extension methods for [AccountType] enum.
///
/// Provides conversion utilities between KMyMoney's numeric codes
/// and the enum values, enabling database serialization.
extension AccountTypeX on AccountType {
  /// Converts KMyMoney numeric type to [AccountType] enum.
  ///
  /// KMyMoney uses numeric codes to represent account types:
  /// - 1: Asset
  /// - 2: Liability
  /// - 10: Income
  /// - 13: Expense
  /// - 12: Equity
  /// - 15: Investment
  ///
  /// Parameters:
  /// - [value]: Numeric string from KMyMoney
  ///
  /// Returns corresponding [AccountType], defaults to [unknown].
  static AccountType fromKmyType(String value) {
    switch (value) {
      case '1':
        return AccountType.asset;
      case '2':
        return AccountType.liability;
      case '10':
        return AccountType.income;
      case '13':
        return AccountType.expense;
      case '12':
        return AccountType.equity;
      case '15':
        return AccountType.investment;
      default:
        return AccountType.unknown;
    }
  }

  /// Converts enum to KMyMoney numeric code for database storage.
  ///
  /// Returns the string representation used by KMyMoney
  /// for each account type.
  ///
  /// Returns numeric string code.
  String get dbValue {
    switch (this) {
      case AccountType.asset:
        return '1';
      case AccountType.liability:
        return '2';
      case AccountType.income:
        return '10';
      case AccountType.expense:
        return '13';
      case AccountType.equity:
        return '12';
      case AccountType.investment:
        return '15';
      case AccountType.unknown:
        return '0';
    }
  }
}
