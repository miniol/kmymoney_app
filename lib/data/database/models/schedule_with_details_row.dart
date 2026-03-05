import '../../../domain/models/money.dart';
import '../../../domain/models/schedule.dart';

class ScheduleWithDetailsRow {
  final String id;
  final ScheduleGroup group;
  final String name;
  final String accountName;
  final String currencyId;
  final Money amount;
  final DateTime nextDueDate;
  final String payee;
  final String frequency;
  final String paymentMethod;

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
