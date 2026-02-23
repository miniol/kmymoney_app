import 'account.dart';
import 'ledger_transaction.dart';

class KmyFile {
  final List<Account> accounts;
  final List<LedgerTransaction> transactions;

  KmyFile({required this.accounts, required this.transactions});
}
