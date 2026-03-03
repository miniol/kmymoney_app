import '../../../domain/models/money.dart';

class AccountWithBalanceRow {
  final String id;
  final String name;
  final String type;
  final String currencyId;
  final Money balance;
  final bool isFavorite;

  AccountWithBalanceRow({
    required this.id,
    required this.name,
    required this.type,
    required this.currencyId,
    required this.balance,
    this.isFavorite = false,
  });
}
