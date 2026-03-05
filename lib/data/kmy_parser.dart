import 'package:xml/xml.dart';
import '../domain/models/account.dart';
import '../domain/models/ledger_transaction.dart';
import '../domain/models/schedule.dart';
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

  List<Schedule> parseSchedules() {
    final schedules = <Schedule>[];

    final scheduleNodes = <XmlElement>[];

    scheduleNodes.addAll(document.findAllElements('SCHEDULED_TX'));
    scheduleNodes.addAll(document.findAllElements('SCHEDULEDTRANSACTION'));
    scheduleNodes.addAll(document.findAllElements('SCHEDULE'));

    for (final node in scheduleNodes) {
      final id = node.getAttribute('id') ?? '';
      final name = node.getAttribute('name') ?? '';

      final typeAttr = node.getAttribute('type') ?? '';
      final groupAttr = (node.getAttribute('group') ?? typeAttr).toLowerCase();

      final group = _groupFromTypeOrHint(typeAttr, groupAttr, name);

      final txNode = node.getElement('TRANSACTION');
      final commodity = txNode?.getAttribute('commodity') ?? '';

      final nextDueRaw =
          node.getAttribute('startDate') ??
          txNode?.getAttribute('postdate') ??
          '';
      final nextDueDate = nextDueRaw.isEmpty
          ? DateTime(1970, 1, 1)
          : _parseKmyDate(nextDueRaw);

      final occurence =
          node.getAttribute('occurence') ??
          node.getAttribute('occurrence') ??
          '';
      final occurenceMultiplier =
          node.getAttribute('occurenceMultiplier') ??
          node.getAttribute('occurrenceMultiplier') ??
          '';

      final frequency = _formatFrequency(occurence, occurenceMultiplier);

      final paymentMethod =
          node.getAttribute('paymentType') ??
          node.getAttribute('payment_method') ??
          node.getAttribute('paymentmethod') ??
          node.getAttribute('paymentMethod') ??
          '';

      final split = _selectPrimaryScheduleSplit(node);

      final payee = split?.getAttribute('payee') ?? '';
      final accountId = split?.getAttribute('account') ?? '';
      final amount = Money.fromString(split?.getAttribute('value') ?? '0/1');

      final currencyId = commodity.isNotEmpty
          ? commodity
          : (node.getAttribute('currency') ?? '');

      schedules.add(
        Schedule(
          id: id,
          group: group,
          name: name,
          accountId: accountId,
          currencyId: currencyId,
          amount: amount,
          nextDueDate: nextDueDate,
          payee: payee,
          frequency: frequency,
          paymentMethod: paymentMethod,
        ),
      );
    }

    return schedules;
  }

  ScheduleGroup _groupFromTypeOrHint(String type, String hint, String name) {
    switch (type.trim()) {
      case '1':
        return ScheduleGroup.bills;
      case '2':
        return ScheduleGroup.deposits;
      case '3':
        return ScheduleGroup.transfers;
      case '4':
        return ScheduleGroup.loans;
    }

    final h = hint.trim();
    final n = name.toLowerCase();

    if (h.contains('deposit') ||
        n.contains('salary') ||
        n.contains('deposit')) {
      return ScheduleGroup.deposits;
    }

    if (h.contains('loan') || n.contains('loan') || n.contains('mortgage')) {
      return ScheduleGroup.loans;
    }

    if (h.contains('transfer') || n.contains('transfer')) {
      return ScheduleGroup.transfers;
    }

    return ScheduleGroup.bills;
  }

  XmlElement? _selectPrimaryScheduleSplit(XmlElement scheduleNode) {
    final splitsParent = scheduleNode
        .getElement('TRANSACTION')
        ?.getElement('SPLITS')
        ?.findElements('SPLIT');

    if (splitsParent == null) return null;

    final splits = splitsParent.toList();
    if (splits.isEmpty) return null;

    for (final s in splits) {
      final value = (s.getAttribute('value') ?? '').trim();
      if (value.startsWith('-')) return s;
    }

    return splits.first;
  }

  String _formatFrequency(String occurence, String multiplier) {
    final occ = occurence.trim();
    final mul = multiplier.trim();

    if (occ.isEmpty && mul.isEmpty) return '';
    if (mul.isEmpty || mul == '1') return occ;
    return '$occ x$mul';
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
