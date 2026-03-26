// Copyright (c) 2026
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// Payee Domain Model
//
// Represents a payee (recipient or payer) from KMyMoney data.

/// Represents a payee (recipient or payer) from KMyMoney.
///
/// A payee is a person or organization that receives money
/// (for expenses) or provides money (for income). This domain model
/// stores the basic identification information for payees.
///
/// Properties:
/// - [id]: Unique identifier from KMyMoney system
/// - [name]: Human-readable payee name
class Payee {
  /// Unique identifier from KMyMoney system.
  final String id;

  /// Human-readable payee name.
  final String name;

  /// Creates a new [Payee] instance.
  ///
  /// Parameters:
  /// - [id]: Unique identifier (required)
  /// - [name]: Payee name (required)
  const Payee({required this.id, required this.name});
}
