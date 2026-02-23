import 'package:decimal/decimal.dart';

class Money {
  final BigInt numerator;
  final BigInt denominator;

  Money(this.numerator, this.denominator);

  factory Money.fromString(String value) {
    final parts = value.split('/');
    return Money(BigInt.parse(parts[0]), BigInt.parse(parts[1]));
  }

  Decimal toDecimal() {
    return (Decimal.fromBigInt(numerator) / Decimal.fromBigInt(denominator))
        .toDecimal();
  }

  Money operator +(Money other) {
    final commonDenom = denominator * other.denominator;
    final newNum =
        numerator * other.denominator + other.numerator * denominator;

    return Money(newNum, commonDenom);
  }
}
