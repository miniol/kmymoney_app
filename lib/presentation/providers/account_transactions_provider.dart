import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/transaction_dao.dart';
import '../../data/database/db_change_notifier.dart';
import '../../domain/models/ledger_transaction.dart';

final accountTransactionsProvider =
    StreamProvider.family<List<LedgerTransaction>, String>((
      ref,
      accountId,
    ) async* {
      final dao = TransactionDao();

      yield await dao.getTransactionsForAccount(accountId);

      await for (final _ in DbChangeNotifier.instance.stream) {
        yield await dao.getTransactionsForAccount(accountId);
      }
    });
