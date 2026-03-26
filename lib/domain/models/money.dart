// Copyright (c) 2026
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// Money Domain Model
//
// Represents monetary values with precise fractional arithmetic.
// Uses BigInt to avoid floating-point precision issues.

import 'package:decimal/decimal.dart';

/// Represents a monetary value with precise fractional arithmetic.
///
/// This class uses BigInt-based fractional representation to avoid
/// floating-point precision issues when dealing with financial calculations.
/// KMyMoney stores monetary values as fractions (numerator/denominator)
/// which this class directly models.
///
/// The fractional approach ensures exact arithmetic for financial operations,
/// unlike floating-point numbers which can introduce rounding errors.
///
/// Examples:
/// ```dart
/// final money = Money.fromString('12345/100'); // $123.45
/// final decimal = money.toDecimal(); // 123.45
/// final sum = money + Money.fromString('678/100'); // $130.23
/// ```
class Money {
  /// Numerator of the fractional representation.
  final BigInt numerator;

  /// Denominator of the fractional representation.
  final BigInt denominator;

  /// Creates a new [Money] instance from numerator and denominator.
  ///
  /// Parameters:
  /// - [numerator]: The numerator of the fractional value
  /// - [denominator]: The denominator of the fractional value
  Money(this.numerator, this.denominator);

  /// Creates a [Money] instance from a KMyMoney string format.
  ///
  /// KMyMoney stores monetary values as "numerator/denominator" strings.
  /// This factory method parses that format into a Money object.
  ///
  /// Parameters:
  /// - [value]: String in "numerator/denominator" format (e.g., "12345/100")
  ///
  /// Returns a new [Money] instance.
  ///
  /// Throws [FormatException] if the string is not in the expected format.
  factory Money.fromString(String value) {
    final parts = value.split('/');
    return Money(BigInt.parse(parts[0]), BigInt.parse(parts[1]));
  }

  /// Converts the fractional value to a Decimal for display purposes.
  ///
  /// This method is useful for formatting money values for UI display
  /// or when decimal arithmetic is preferred over fractional.
  ///
  /// Returns a [Decimal] representation of the monetary value.
  Decimal toDecimal() {
    return (Decimal.fromBigInt(numerator) / Decimal.fromBigInt(denominator))
        .toDecimal();
  }

  /// Adds two Money values using exact fractional arithmetic.
  ///
  /// This operation finds a common denominator and adds the numerators,
  /// preserving exact precision without floating-point errors.
  ///
  /// Parameters:
  /// - [other]: The Money value to add
  ///
  /// Returns a new [Money] instance representing the sum.
  Money operator +(Money other) {
    // Find common denominator for exact addition
    final commonDenom = denominator * other.denominator;
    final newNum =
        numerator * other.denominator + other.numerator * denominator;

    return Money(newNum, commonDenom);
  }
}
