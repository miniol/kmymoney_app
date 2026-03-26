// Copyright (c) 2026
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// Schedule Domain Model
//
// Represents scheduled transactions from KMyMoney data.
// Includes schedule grouping and metadata.

import 'money.dart';

/// Represents the category/group of a scheduled transaction.
///
/// KMyMoney organizes schedules into logical groups for better
/// organization and filtering. These groups help users understand
/// the nature of their scheduled transactions.
enum ScheduleGroup {
  /// Regular bills and expenses (utilities, subscriptions, etc.)
  bills,

  /// Income and deposits (salary, dividends, etc.)
  deposits,

  /// Loan payments and credit obligations
  loans,

  /// Account transfers between own accounts
  transfers,
}

/// Extension methods for [ScheduleGroup] enum.
///
/// Provides utility methods for converting between database
/// string values and enum values, enabling easy serialization.
extension ScheduleGroupX on ScheduleGroup {
  /// Converts a string value to [ScheduleGroup] enum.
  ///
  /// Used when reading schedule groups from database or API.
  /// Defaults to [ScheduleGroup.bills] for unknown values.
  ///
  /// Parameters:
  /// - [value]: String representation of the group
  ///
  /// Returns the corresponding [ScheduleGroup] enum.
  static ScheduleGroup fromString(String value) {
    switch (value) {
      case 'bills':
        return ScheduleGroup.bills;
      case 'deposits':
        return ScheduleGroup.deposits;
      case 'loans':
        return ScheduleGroup.loans;
      case 'transfers':
        return ScheduleGroup.transfers;
      default:
        return ScheduleGroup.bills;
    }
  }

  /// Converts the enum to a database-friendly string value.
  ///
  /// Used when persisting schedule groups to database.
  ///
  /// Returns the string representation for storage.
  String get dbValue {
    switch (this) {
      case ScheduleGroup.bills:
        return 'bills';
      case ScheduleGroup.deposits:
        return 'deposits';
      case ScheduleGroup.loans:
        return 'loans';
      case ScheduleGroup.transfers:
        return 'transfers';
    }
  }
}

/// Represents a scheduled transaction from KMyMoney.
///
/// This domain model captures all essential information about
/// recurring transactions including timing, amounts, and associated
/// accounts and payees.
///
/// Properties:
/// - [id]: Unique identifier from KMyMoney
/// - [group]: Category for organization (bills, deposits, etc.)
/// - [name]: Human-readable schedule name
/// - [accountId]: Associated account ID
/// - [currencyId]: Currency for the transaction
/// - [amount]: Transaction amount
/// - [nextDueDate]: When the transaction is next due
/// - [payee]: Recipient or payer name
/// - [frequency]: How often the transaction recurs
/// - [paymentMethod]: How the payment is made
class Schedule {
  /// Unique identifier from KMyMoney system.
  final String id;

  /// Category for organizing schedules.
  final ScheduleGroup group;

  /// Human-readable schedule name.
  final String name;

  /// Associated account ID.
  final String accountId;

  /// Currency code for the transaction.
  final String currencyId;

  /// Transaction amount.
  final Money amount;

  /// When the transaction is next due.
  final DateTime nextDueDate;

  /// Recipient or payer name.
  final String payee;

  /// How often the transaction recurs.
  final String frequency;

  /// Payment method description.
  final String paymentMethod;

  /// Creates a new [Schedule] instance.
  ///
  /// All parameters are required for a complete schedule definition.
  const Schedule({
    required this.id,
    required this.group,
    required this.name,
    required this.accountId,
    required this.currencyId,
    required this.amount,
    required this.nextDueDate,
    required this.payee,
    required this.frequency,
    required this.paymentMethod,
  });
}
