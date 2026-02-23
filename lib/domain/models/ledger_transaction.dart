import 'split.dart';

class LedgerTransaction {
  final String id;
  final DateTime date;
  final List<Split> splits;

  LedgerTransaction({
    required this.id,
    required this.date,
    required this.splits,
  });
}
