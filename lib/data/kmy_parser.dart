import 'package:xml/xml.dart';
import '../domain/models/account.dart';
import '../domain/models/ledger_transaction.dart';
import '../domain/models/split.dart';
import '../domain/models/money.dart';

class KmyParser {
  late XmlDocument document;

  KmyParser(String xmlString) {
    document = XmlDocument.parse(xmlString);
  }

  List<Account> parseAccounts() {
    final accounts = <Account>[];

    final accountNodes = document.findAllElements('ACCOUNT');

    for (final node in accountNodes) {
      accounts.add(
        Account(
          id: node.getAttribute('id') ?? '',
          name: node.getAttribute('name') ?? '',
          type: node.getAttribute('type') ?? '',
          currencyId: node.getAttribute('currency') ?? '',
        ),
      );
    }

    return accounts;
  }

  List<LedgerTransaction> parseTransactions() {
    final transactions = <LedgerTransaction>[];

    final txNodes = document.findAllElements('TRANSACTION');

    for (final tx in txNodes) {
      final splits = <Split>[];

      final splitNodes = tx.findAllElements('SPLIT');

      for (final split in splitNodes) {
        splits.add(
          Split(
            accountId: split.getAttribute('account') ?? '',
            value: Money.fromString(split.getAttribute('value') ?? '0/1'),
          ),
        );
      }

      transactions.add(
        LedgerTransaction(
          id: tx.getAttribute('id') ?? '',
          date: DateTime.parse(tx.getAttribute('postdate') ?? ''),
          splits: splits,
        ),
      );
    }

    return transactions;
  }
}
