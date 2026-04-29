// Copyright (c) 2026 by Zafado.pl
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// KMyMoney Repository Implementation
//
// Concrete implementation of the repository interface.
// Orchestrates file loading, parsing, and database operations.

import 'package:flutter/foundation.dart';

import '../../domain/repositories/kmy_repository.dart';
import '../../domain/models/account.dart';
import '../../domain/models/ledger_transaction.dart';
import '../../domain/models/money.dart';
import '../../domain/models/payee.dart';
import '../../domain/models/schedule.dart';
import '../../domain/models/split.dart';
import '../kmy_file_loader.dart';
import '../kmy_parser.dart';
import '../database/account_dao.dart';
import '../database/payee_dao.dart';
import '../database/schedule_dao.dart';
import '../database/transaction_dao.dart';

Map<String, dynamic> _parseKmyToWireFormat(String xmlString) {
  final parser = KmyParser(xmlString);

  final accounts = parser.parseAccounts();
  final payees = parser.parsePayees();
  final transactions = parser.parseTransactions();
  final schedules = parser.parseSchedules();

  return {
    'accounts': accounts
        .map(
          (a) => {
            'id': a.id,
            'name': a.name,
            'type': a.type,
            'currencyId': a.currencyId,
            'closed': a.closed,
            'preferred': a.preferred,
          },
        )
        .toList(growable: false),
    'payees': payees
        .map((p) => {'id': p.id, 'name': p.name})
        .toList(growable: false),
    'transactions': transactions
        .map(
          (t) => {
            'id': t.id,
            'date': t.date.toIso8601String(),
            'memo': t.memo,
            'entryDate': t.entryDate,
            'commodity': t.commodity,
            'extraAttributes': t.extraAttributes,
            'extraInnerXml': t.extraInnerXml,
            'splits': t.splits
                .map(
                  (s) => {
                    'id': s.id,
                    'accountId': s.accountId,
                    'numerator': s.value.numerator.toString(),
                    'denominator': s.value.denominator.toString(),
                    'sharesNumerator': s.shares.numerator.toString(),
                    'sharesDenominator': s.shares.denominator.toString(),
                    'priceNumerator': s.price.numerator.toString(),
                    'priceDenominator': s.price.denominator.toString(),
                    'payeeId': s.payeeId,
                    'reconcileDate': s.reconcileDate,
                    'reconcileFlag': s.reconcileFlag,
                    'action': s.action,
                    'memo': s.memo,
                    'number': s.number,
                    'bankId': s.bankId,
                    'extraAttributes': s.extraAttributes,
                  },
                )
                .toList(growable: false),
          },
        )
        .toList(growable: false),
    'schedules': schedules
        .map(
          (s) => {
            'id': s.id,
            'group': s.group.dbValue,
            'name': s.name,
            'accountId': s.accountId,
            'currencyId': s.currencyId,
            'amountNumerator': s.amount.numerator.toString(),
            'amountDenominator': s.amount.denominator.toString(),
            'nextDueDate': s.nextDueDate.toIso8601String(),
            'payee': s.payee,
            'frequency': s.frequency,
            'paymentMethod': s.paymentMethod,
          },
        )
        .toList(growable: false),
  };
}

List<Account> _wireAccounts(dynamic raw) {
  final list = (raw as List).cast<Map>();
  return list
      .map(
        (m) => Account(
          id: m['id'] as String,
          name: m['name'] as String,
          type: m['type'] as String,
          currencyId: m['currencyId'] as String,
          closed: m['closed'] as bool,
          preferred: m['preferred'] as bool,
        ),
      )
      .toList(growable: false);
}

List<Payee> _wirePayees(dynamic raw) {
  final list = (raw as List).cast<Map>();
  return list
      .map((m) => Payee(id: m['id'] as String, name: m['name'] as String))
      .toList(growable: false);
}

List<LedgerTransaction> _wireTransactions(dynamic raw) {
  final list = (raw as List).cast<Map>();
  return list
      .map((m) {
        final splitMaps = (m['splits'] as List).cast<Map>();
        final splits = splitMaps
            .map(
              (s) => Split(
                id: (s['id'] as String?) ?? '',
                accountId: s['accountId'] as String,
                value: Money(
                  BigInt.parse(s['numerator'] as String),
                  BigInt.parse(s['denominator'] as String),
                ),
                shares: Money(BigInt.zero, BigInt.one),
                price: Money(BigInt.one, BigInt.one),
                payeeId: '',
                reconcileDate: '',
                reconcileFlag: '0',
                action: '',
                memo: '',
                number: '',
                bankId: '',
                extraAttributes: const {},
              ),
            )
            .toList(growable: false);

        return LedgerTransaction(
          id: m['id'] as String,
          date: DateTime.parse(m['date'] as String),
          splits: splits,
          memo: '',
          entryDate: '',
          commodity: '',
          extraAttributes: const {},
          extraInnerXml: '',
        );
      })
      .toList(growable: false);
}

List<Schedule> _wireSchedules(dynamic raw) {
  final list = (raw as List).cast<Map>();
  return list
      .map(
        (m) => Schedule(
          id: m['id'] as String,
          group: ScheduleGroupX.fromString(m['group'] as String),
          name: m['name'] as String,
          accountId: m['accountId'] as String,
          currencyId: m['currencyId'] as String,
          amount: Money(
            BigInt.parse(m['amountNumerator'] as String),
            BigInt.parse(m['amountDenominator'] as String),
          ),
          nextDueDate: DateTime.parse(m['nextDueDate'] as String),
          payee: m['payee'] as String,
          frequency: m['frequency'] as String,
          paymentMethod: m['paymentMethod'] as String,
        ),
      )
      .toList(growable: false);
}

class KmyRepositoryImpl implements KmyRepository {
  final _accountDao = AccountDao();
  final _payeeDao = PayeeDao();
  final _scheduleDao = ScheduleDao();
  final _transactionDao = TransactionDao();

  @override
  Future<void> loadFromPath(String path) async {
    final xmlString = await KmyFileLoader.load(path);

    final wire = await compute(_parseKmyToWireFormat, xmlString);

    final accounts = _wireAccounts(wire['accounts']);
    final payees = _wirePayees(wire['payees']);
    final transactions = _wireTransactions(wire['transactions']);
    final schedules = _wireSchedules(wire['schedules']);

    // Clear old data
    await _transactionDao.clear();
    await _scheduleDao.clear();
    await _payeeDao.clear();
    await _accountDao.clear();

    // Insert fresh data
    await _accountDao.insertAccounts(accounts);
    await _payeeDao.insertPayees(payees);
    await _transactionDao.insertTransactions(transactions);
    await _scheduleDao.insertSchedules(schedules);
  }
}
