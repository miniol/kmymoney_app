import 'package:sqflite/sqflite.dart';
import '../../domain/models/ledger_transaction.dart';
import '../../domain/models/split.dart';
import '../../domain/models/money.dart';
import 'app_database.dart';
import 'db_change_notifier.dart';

class TransactionDao {
  Future<void> insertTransactions(List<LedgerTransaction> transactions) async {
    final db = await AppDatabase.instance.database;

    final batch = db.batch();

    for (final tx in transactions) {
      batch.insert('transactions', {
        'id': tx.id,
        'post_date': tx.date.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      for (final split in tx.splits) {
        batch.insert('splits', {
          'transaction_id': tx.id,
          'account_id': split.accountId,
          'numerator': split.value.numerator.toString(),
          'denominator': split.value.denominator.toString(),
        });
      }
    }

    await batch.commit(noResult: true);
    // notify that transactions have been updated
    DbChangeNotifier.instance.notify();
  }

  Future<List<LedgerTransaction>> getTransactions() async {
    final db = await AppDatabase.instance.database;

    final txMaps = await db.query('transactions');

    final splitMaps = await db.query('splits');

    return txMaps.map((txMap) {
      final txId = txMap['id'] as String;

      final splits = splitMaps.where((s) => s['transaction_id'] == txId).map((
        s,
      ) {
        return Split(
          accountId: s['account_id'] as String,
          value: Money(
            BigInt.parse(s['numerator'] as String),
            BigInt.parse(s['denominator'] as String),
          ),
        );
      }).toList();

      return LedgerTransaction(
        id: txId,
        date: DateTime.parse(txMap['post_date'] as String),
        splits: splits,
      );
    }).toList();
  }

  Future<void> clear() async {
    final db = await AppDatabase.instance.database;
    await db.delete('splits');
    await db.delete('transactions');
    // notify that transactions have been updated
    DbChangeNotifier.instance.notify();
  }

  Future<List<LedgerTransaction>> getTransactionsForAccount(
    String accountId,
  ) async {
    final db = await AppDatabase.instance.database;

    final txMaps = await db.rawQuery(
      '''
    SELECT DISTINCT t.id, t.post_date
    FROM transactions t
    INNER JOIN splits s
      ON t.id = s.transaction_id
    WHERE s.account_id = ?
    ORDER BY t.post_date DESC
  ''',
      [accountId],
    );

    final splitMaps = await db.query(
      'splits',
      where: 'account_id = ?',
      whereArgs: [accountId],
    );

    return txMaps.map((txMap) {
      final txId = txMap['id'] as String;

      final splits = splitMaps.where((s) => s['transaction_id'] == txId).map((
        s,
      ) {
        return Split(
          accountId: s['account_id'] as String,
          value: Money(
            BigInt.parse(s['numerator'] as String),
            BigInt.parse(s['denominator'] as String),
          ),
        );
      }).toList();

      return LedgerTransaction(
        id: txId,
        date: DateTime.parse(txMap['post_date'] as String),
        splits: splits,
      );
    }).toList();
  }
}
