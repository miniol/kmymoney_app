import 'money.dart';

enum ScheduleGroup { bills, deposits, loans, transfers }

extension ScheduleGroupX on ScheduleGroup {
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

class Schedule {
  final String id;
  final ScheduleGroup group;
  final String name;
  final String accountId;
  final String currencyId;
  final Money amount;
  final DateTime nextDueDate;
  final String payee;
  final String frequency;
  final String paymentMethod;

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
