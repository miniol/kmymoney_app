// Copyright (c) 2026 by Zafado.pl
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// Schedule with Details Row Model
//
// Database row model for schedules with joined account details.
// Used in queries that need complete schedule information.

import '../../../domain/models/money.dart';
import '../../../domain/models/schedule.dart';

/// Database row model representing a schedule with joined account details.
///
/// This model is used for database queries that join schedules
/// with accounts and payees to provide complete information
/// for UI display. It includes all schedule data plus
/// resolved account names and currency information.
///
/// Properties:
/// - [id]: Schedule identifier
/// - [group]: Schedule category group
/// - [name]: Schedule display name
/// - [accountName]: Resolved account name from join
/// - [currencyId]: Currency code for the amount
/// - [amount]: Scheduled amount
/// - [nextDueDate]: Next payment due date
/// - [payee]: Payee name or identifier
/// - [frequency]: Payment frequency description
/// - [paymentMethod]: Payment method description
class ScheduleWithDetailsRow {
  /// Schedule identifier from database.
  final String id;

  /// Schedule category group.
  final ScheduleGroup group;

  /// Schedule display name.
  final String name;

  /// Resolved account name from database join.
  final String accountName;

  /// Currency code for the amount.
  final String currencyId;

  /// Scheduled payment amount.
  final Money amount;

  /// Next payment due date.
  final DateTime nextDueDate;

  /// Payee name or identifier.
  final String payee;

  /// Payment frequency description.
  final String frequency;

  /// Payment method description.
  final String paymentMethod;

  /// Creates a new [ScheduleWithDetailsRow] instance.
  ///
  /// All parameters are required as this represents
  /// complete schedule information from a database query.
  const ScheduleWithDetailsRow({
    required this.id,
    required this.group,
    required this.name,
    required this.accountName,
    required this.currencyId,
    required this.amount,
    required this.nextDueDate,
    required this.payee,
    required this.frequency,
    required this.paymentMethod,
  });
}
