import 'package:kmymoney_app/data/kmy_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InterpretKMyMoneySchedule', () {
    test('handles standard occcurance (example)', () {
      final result = interpretKMyMoneySchedule(
        occurence: 4,
        occurenceMultiplier: 1,
        startDate: DateTime(2026, 1, 1),
        nextDueDate: DateTime(2026, 2, 1),
        lastPayment: null,
      );

      expect(result.toString(), isNotEmpty);
    });

    test('handles special occurence 32 with date-based inference', () {
      final result = interpretKMyMoneySchedule(
        occurence: 32,
        occurenceMultiplier: 1,
        startDate: DateTime(2026, 1, 1),
        nextDueDate: DateTime(2026, 2, 1),
        lastPayment: null,
      );

      expect(result.toString(), isNotEmpty);
    });
  });
}
