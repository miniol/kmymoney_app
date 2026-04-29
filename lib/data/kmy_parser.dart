// Copyright (c) 2026 by Zafado.pl
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT
//
// KMyMoney XML Parser
//
// Handles parsing of KMyMoney export files into Flutter domain models.
// Supports accounts, transactions, payees, and scheduled transactions.

import 'package:xml/xml.dart';
import '../domain/models/account.dart';
import '../domain/models/ledger_transaction.dart';
import '../domain/models/payee.dart';
import '../domain/models/schedule.dart';
import '../domain/models/split.dart';
import '../domain/models/money.dart';

/// Represents the frequency of scheduled transactions in KMyMoney.
///
/// Each enum value corresponds to a different recurrence pattern
/// supported by KMyMoney's scheduling system.
enum ScheduleFrequency {
  once,
  daily,
  weekly,
  biweekly,
  halfMonth,
  monthly,
  everyTwoMonths,
  quarterly,
  everyFourMonths,
  semiannual,
  yearly,
  everyTwoYears,
  custom,
}

/// Represents the interpretation of a KMyMoney schedule.
///
/// Contains both the frequency type and multiplier to describe
/// how often a scheduled transaction occurs.
///
/// Properties:
/// - [frequency]: The type of frequency (daily, monthly, etc.)
/// - [multiplier]: How many times the frequency repeats (1 = normal, 2 = every two periods, etc.)
class ScheduleInterpretation {
  final ScheduleFrequency frequency;
  final int multiplier;

  ScheduleInterpretation(this.frequency, this.multiplier);

  String get displayName {
    switch (frequency) {
      case ScheduleFrequency.once:
        return 'Once';
      case ScheduleFrequency.daily:
        return 'Daily';
      case ScheduleFrequency.weekly:
        return 'Weekly';
      case ScheduleFrequency.biweekly:
        return 'Biweekly';
      case ScheduleFrequency.halfMonth:
        return 'Half-month';
      case ScheduleFrequency.monthly:
        return 'Monthly';
      case ScheduleFrequency.everyTwoMonths:
        return 'Every two months';
      case ScheduleFrequency.quarterly:
        return 'Quarterly';
      case ScheduleFrequency.everyFourMonths:
        return 'Every four months';
      case ScheduleFrequency.semiannual:
        return 'Semiannual';
      case ScheduleFrequency.yearly:
        return 'Yearly';
      case ScheduleFrequency.everyTwoYears:
        return 'Every two years';
      case ScheduleFrequency.custom:
        return 'Custom';
    }
  }

  @override
  String toString() {
    final m = multiplier <= 0 ? 1 : multiplier;
    if (m == 1) return displayName;
    return '$displayName x$m';
  }
}

/// Interprets KMyMoney schedule data into a human-readable format.
///
/// Takes schedule occurrence codes and date information to determine
/// the actual frequency and recurrence pattern of scheduled transactions.
///
/// This function handles KMyMoney's internal encoding of schedules:
/// - Standard codes (1-11) map to predefined frequencies
/// - Code 32 represents "once" or inferred monthly/yearly patterns
/// - Code 16384 represents custom schedules
///
/// Parameters:
/// - [occurence]: The schedule occurrence code from KMyMoney
/// - [occurenceMultiplier]: How often the occurrence repeats (defaults to 1)
/// - [startDate]: When the schedule originally started
/// - [nextDueDate]: When the next payment is due
/// - [lastPayment]: Optional last payment date for better frequency inference
///
/// Returns a [ScheduleInterpretation] containing the decoded frequency and multiplier.
ScheduleInterpretation interpretKMyMoneySchedule({
  required int occurence,
  required int occurenceMultiplier,
  required DateTime startDate,
  required DateTime nextDueDate,
  DateTime? lastPayment,
}) {
  const standardMap = {
    1: ScheduleFrequency.daily,
    2: ScheduleFrequency.weekly,
    3: ScheduleFrequency.biweekly,
    4: ScheduleFrequency.halfMonth,
    5: ScheduleFrequency.monthly,
    6: ScheduleFrequency.everyTwoMonths,
    7: ScheduleFrequency.quarterly,
    8: ScheduleFrequency.everyFourMonths,
    9: ScheduleFrequency.semiannual,
    10: ScheduleFrequency.yearly,
    11: ScheduleFrequency.everyTwoYears,
  };

  if (standardMap.containsKey(occurence)) {
    return ScheduleInterpretation(standardMap[occurence]!, occurenceMultiplier);
  }

  if (occurence == 32) {
    if (lastPayment != null) {
      final diff = nextDueDate.difference(lastPayment).inDays;

      if (diff >= 28 && diff <= 31) {
        return ScheduleInterpretation(ScheduleFrequency.monthly, 1);
      }
      if (diff >= 55 && diff <= 62) {
        return ScheduleInterpretation(ScheduleFrequency.everyTwoMonths, 1);
      }
      if (diff >= 85 && diff <= 95) {
        return ScheduleInterpretation(ScheduleFrequency.quarterly, 1);
      }
      if (diff >= 360 && diff <= 370) {
        return ScheduleInterpretation(ScheduleFrequency.yearly, 1);
      }
    }

    return ScheduleInterpretation(ScheduleFrequency.once, 1);
  }

  if (occurence == 16384) {
    final diff = nextDueDate.difference(startDate).inDays;

    if (diff >= 28 && diff <= 31) {
      return ScheduleInterpretation(ScheduleFrequency.monthly, 1);
    }
    if (diff >= 55 && diff <= 62) {
      return ScheduleInterpretation(ScheduleFrequency.everyTwoMonths, 1);
    }
    if (diff >= 85 && diff <= 95) {
      return ScheduleInterpretation(ScheduleFrequency.quarterly, 1);
    }
    if (diff >= 360 && diff <= 370) {
      return ScheduleInterpretation(ScheduleFrequency.yearly, 1);
    }

    return ScheduleInterpretation(ScheduleFrequency.custom, 1);
  }

  return ScheduleInterpretation(ScheduleFrequency.custom, occurenceMultiplier);
}

/// Parses KMyMoney XML files into domain models.
///
/// This class handles the extraction and parsing of financial data
/// from KMyMoney's XML export format, including accounts, transactions,
/// payees, and scheduled transactions.
///
/// Properties:
/// - [document]: The parsed XML document
///
/// Throws:
/// - [XmlParserException] if the XML is malformed.
///
/// Usage:
/// ```dart
/// final parser = KmyParser(xmlString);
/// final accounts = parser.parseAccounts();
/// final transactions = parser.parseTransactions();
/// final payees = parser.parsePayees();
/// final schedules = parser.parseSchedules();
/// ```
class KmyParser {
  late XmlDocument document;

  KmyParser(String xmlString) {
    document = XmlDocument.parse(xmlString);
  }

  List<Account> parseAccounts() {
    final accountsById = <String, Account>{};

    final accountNodes = document.findAllElements('ACCOUNT');

    for (final node in accountNodes) {
      bool isClosed = false;
      bool isPreferred = false;

      final kvElements = node.findElements('KEYVALUEPAIRS');

      if (kvElements.isNotEmpty) {
        final kvNode = kvElements.first;

        for (final pair in kvNode.findElements('PAIR')) {
          final key = pair.getAttribute('key');
          final value = pair.getAttribute('value');

          if (key == 'mm-closed' && value == 'yes') {
            isClosed = true;
          }

          if (key == 'PreferredAccount' && value == 'Yes') {
            isPreferred = true;
          }
        }
      }

      final id = (node.getAttribute('id') ?? '').trim();
      if (id.isEmpty) continue;

      final next = Account(
        id: id,
        name: (node.getAttribute('name') ?? '').trim(),
        type: (node.getAttribute('type') ?? '').trim(),
        currencyId: (node.getAttribute('currency') ?? '').trim(),
        closed: isClosed,
        preferred: isPreferred,
      );

      final existing = accountsById[id];
      if (existing == null) {
        accountsById[id] = next;
      } else {
        accountsById[id] = Account(
          id: id,
          name: next.name.isNotEmpty ? next.name : existing.name,
          type: next.type.isNotEmpty ? next.type : existing.type,
          currencyId: next.currencyId.isNotEmpty
              ? next.currencyId
              : existing.currencyId,
          closed: existing.closed || next.closed,
          preferred: existing.preferred || next.preferred,
        );
      }
    }
    return accountsById.values.toList();
  }

  List<Payee> parsePayees() {
    final payees = <Payee>[];

    final payeeNodes = document.findAllElements('PAYEE');

    for (final node in payeeNodes) {
      final id = node.getAttribute('id') ?? '';
      if (id.isEmpty) continue;

      payees.add(Payee(id: id, name: node.getAttribute('name') ?? ''));
    }

    return payees;
  }

  List<LedgerTransaction> parseTransactions() {
    final transactions = <LedgerTransaction>[];

    final txNodes =
        document.rootElement
            .getElement('TRANSACTIONS')
            ?.findElements('TRANSACTION') ??
        const Iterable<XmlElement>.empty();

    for (final tx in txNodes) {
      final txId = tx.getAttribute('id') ?? '';
      final rawDate = tx.getAttribute('postdate') ?? '';

      final memo = tx.getAttribute('memo') ?? '';
      final entryDate = tx.getAttribute('entrydate') ?? '';
      final commodity = tx.getAttribute('commodity') ?? '';

      final txExtraAttrs = _attrsExcept(tx, {
        'id',
        'postdate',
        'memo',
        'entrydate',
        'commodity',
      });

      final splitNodes = tx.findAllElements('SPLIT');
      final splits = <Split>[];

      for (final split in splitNodes) {
        final splitId = split.getAttribute('id') ?? '';
        final accountId = split.getAttribute('account') ?? '';

        final value = Money.fromString(split.getAttribute('value') ?? '0/1');
        final shares = Money.fromString(split.getAttribute('shares') ?? '0/1');
        final price = Money.fromString(split.getAttribute('price') ?? '1/1');

        final payeeId = split.getAttribute('payee') ?? '';
        final reconcileDate = split.getAttribute('reconciledate') ?? '';
        final reconcileFlag = split.getAttribute('reconcileflag') ?? '0';
        final action = split.getAttribute('action') ?? '';
        final splitMemo = split.getAttribute('memo') ?? '';
        final number = split.getAttribute('number') ?? '';
        final bankId = split.getAttribute('bankid') ?? '';

        final splitExtraAttrs = _attrsExcept(split, {
          'id',
          'account',
          'value',
          'shares',
          'price',
          'payee',
          'reconciledate',
          'reconcileflag',
          'action',
          'memo',
          'number',
          'bankid',
        });

        splits.add(
          Split(
            id: splitId,
            accountId: accountId,
            value: value,
            shares: shares,
            price: price,
            payeeId: payeeId,
            reconcileDate: reconcileDate,
            reconcileFlag: reconcileFlag,
            action: action,
            memo: splitMemo,
            number: number,
            bankId: bankId,
            extraAttributes: splitExtraAttrs,
          ),
        );
      }

      transactions.add(
        LedgerTransaction(
          id: txId,
          date: _parseKmyDate(rawDate),
          splits: splits,
          memo: memo,
          entryDate: entryDate,
          commodity: commodity,
          extraAttributes: txExtraAttrs,
          extraInnerXml: '',
        ),
      );
    }

    return transactions;
  }

  List<Schedule> parseSchedules() {
    final schedules = <Schedule>[];

    final scheduleNodes = <XmlElement>[];

    scheduleNodes.addAll(document.findAllElements('SCHEDULED_TX'));

    for (final node in scheduleNodes) {
      final id = node.getAttribute('id') ?? '';
      final name = node.getAttribute('name') ?? '';

      final typeAttr = node.getAttribute('type') ?? '';
      final groupAttr = (node.getAttribute('group') ?? typeAttr).toLowerCase();

      final group = _groupFromTypeOrHint(typeAttr, groupAttr, name);

      final txNode = node.getElement('TRANSACTION');
      final commodity = txNode?.getAttribute('commodity') ?? '';

      final startDateRaw = node.getAttribute('startDate') ?? '';
      final startDate = startDateRaw.isEmpty
          ? DateTime(1970, 1, 1)
          : _parseKmyDate(startDateRaw);

      final nextDueRaw =
          node.getAttribute('nextDueDate') ??
          node.getAttribute('nextdue') ??
          node.getAttribute('nextDue') ??
          txNode?.getAttribute('postdate') ??
          node.getAttribute('startDate') ??
          '';
      final nextDueDate = nextDueRaw.isEmpty
          ? DateTime(1970, 1, 1)
          : _parseKmyDate(nextDueRaw);

      final lastPaymentRaw = node.getAttribute('lastPayment') ?? '';
      final lastPayment = lastPaymentRaw.isEmpty
          ? null
          : _parseKmyDate(lastPaymentRaw);

      final occurence =
          node.getAttribute('occurence') ??
          node.getAttribute('occurrence') ??
          '';
      final occurenceMultiplier =
          node.getAttribute('occurenceMultiplier') ??
          node.getAttribute('occurrenceMultiplier') ??
          '';

      final occurenceInt = _parseIntSafe(occurence);
      final occurenceMultiplierInt = _parseIntSafe(
        occurenceMultiplier,
        fallback: 1,
      );

      final frequency = interpretKMyMoneySchedule(
        occurence: occurenceInt,
        occurenceMultiplier: occurenceMultiplierInt,
        startDate: startDate,
        nextDueDate: nextDueDate,
        lastPayment: lastPayment,
      ).toString();

      final paymentMethod =
          node.getAttribute('paymentType') ??
          node.getAttribute('payment_method') ??
          node.getAttribute('paymentmethod') ??
          node.getAttribute('paymentMethod') ??
          '';

      final paymentMethodLabel = _decodePaymentType(paymentMethod);

      final split = _selectPrimaryScheduleSplit(node, scheduleType: typeAttr);
      final allSplits = _listScheduleSplits(node);

      final payee =
          ((split?.getAttribute('payee') ?? '').trim().isNotEmpty
                  ? (split?.getAttribute('payee') ?? '')
                  : _firstNonEmptyAttr(allSplits, 'payee'))
              .trim();

      final accountId =
          ((split?.getAttribute('account') ?? '').trim().isNotEmpty
                  ? (split?.getAttribute('account') ?? '')
                  : _firstNonEmptyAttr(allSplits, 'account'))
              .trim();
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
          paymentMethod: paymentMethodLabel,
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

  XmlElement? _selectPrimaryScheduleSplit(
    XmlElement scheduleNode, {
    String scheduleType = '',
  }) {
    final splits = _listScheduleSplits(scheduleNode);
    if (splits.isEmpty) return null;

    final type = scheduleType.trim();
    final preferPositive = type == '2';

    for (final s in splits) {
      final value = (s.getAttribute('value') ?? '').trim();
      if (preferPositive && value.isNotEmpty && !value.startsWith('-')) {
        return s;
      }
      if (!preferPositive && value.startsWith('-')) {
        return s;
      }
    }

    for (final s in splits) {
      final account = (s.getAttribute('account') ?? '').trim();
      if (account.isNotEmpty) return s;
    }

    return splits.first;
  }

  List<XmlElement> _listScheduleSplits(XmlElement scheduleNode) {
    return scheduleNode
            .getElement('TRANSACTION')
            ?.getElement('SPLITS')
            ?.findElements('SPLIT')
            .toList() ??
        <XmlElement>[];
  }

  String _firstNonEmptyAttr(List<XmlElement> elements, String attr) {
    for (final el in elements) {
      final v = (el.getAttribute(attr) ?? '').trim();
      if (v.isNotEmpty) return v;
    }
    return '';
  }

  int _parseIntSafe(String value, {int fallback = 0}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return fallback;
    return int.tryParse(trimmed) ?? fallback;
  }

  String _decodePaymentType(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';

    final code = int.tryParse(trimmed);
    if (code == null) return trimmed;
    if (code == 0) return '';

    const bitNames = <int, String>{
      1: 'Direct deposit',
      2: 'Direct debit',
      4: 'Manual deposit',
      8: 'Manual withdrawal',
      16: 'Write cheque',
      32: 'Standing order',
      64: 'Bank transfer',
    };

    final parts = <String>[];
    for (final entry in bitNames.entries) {
      if ((code & entry.key) != 0) {
        parts.add(entry.value);
      }
    }

    if (parts.isEmpty) return 'Unknown ($code)';
    return parts.join(', ');
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

  Map<String, String> _attrsExcept(XmlElement el, Set<String> exclude) {
    final out = <String, String>{};
    for (final a in el.attributes) {
      final k = a.name.local;
      if (exclude.contains(k)) continue;
      out[k] = a.value;
    }
    return out;
  }
}
