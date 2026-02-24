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
      bool isClosed = false;

      final kvElements = node.findElements('KEYVALUEPAIRS');

      if (kvElements.isNotEmpty) {
        final kvNode = kvElements.first;

        for (final pair in kvNode.findElements('PAIR')) {
          final key = pair.getAttribute('key');
          final value = pair.getAttribute('value');

          if (key == 'mm-closed' && value == 'yes') {
            isClosed = true;
          }
        }
      }

      accounts.add(
        Account(
          id: node.getAttribute('id') ?? '',
          name: node.getAttribute('name') ?? '',
          type: node.getAttribute('type') ?? '',
          currencyId: node.getAttribute('currency') ?? '',
          closed: isClosed,
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

      final rawDate = tx.getAttribute('postdate') ?? '';

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
          date: _parseKmyDate(rawDate),
          splits: splits,
        ),
      );
    }

    return transactions;
  }

  DateTime _parseKmyDate(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      // fallback date or throw controlled exception
      return DateTime(1970, 1, 1);
    }

    final eightDigit = RegExp(r'^\d{8}$');
    if (eightDigit.hasMatch(trimmed)) {
      final year = int.parse(trimmed.substring(0, 4));
      final month = int.parse(trimmed.substring(4, 6));
      final day = int.parse(trimmed.substring(6, 8));
      return DateTime(year, month, day);
    }

    return DateTime.parse(trimmed);
  }
}
