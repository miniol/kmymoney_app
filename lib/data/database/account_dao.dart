import 'package:sqflite/sqflite.dart';
import '../../domain/models/account.dart';
import 'app_database.dart';
import 'db_change_notifier.dart';
import '../../domain/models/money.dart';
import 'models/account_with_balance_row.dart';

class AccountDao {
  Future<void> insertAccounts(List<Account> accounts) async {
    final db = await AppDatabase.instance.database;

    final batch = db.batch();

    for (final account in accounts) {
      batch.insert('accounts', {
        'id': account.id,
        'name': account.name,
        'type': account.type,
        'currency_id': account.currencyId,
        'closed': account.closed ? 1 : 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
    // notify that accounts have been updated
    DbChangeNotifier.instance.notify();
  }

  Future<List<Account>> getAccounts() async {
    final db = await AppDatabase.instance.database;

    final maps = await db.query('accounts');

    return maps.map((map) {
      return Account(
        id: map['id'] as String,
        name: map['name'] as String,
        type: map['type'] as String,
        currencyId: map['currency_id'] as String,
        closed: map['closed'] == '1',
      );
    }).toList();
  }

  Future<void> clear() async {
    final db = await AppDatabase.instance.database;
    await db.delete('accounts');
    // notify that accounts have been updated
    DbChangeNotifier.instance.notify();
  }

  Future<List<AccountWithBalanceRow>> getAccountsWithBalances() async {
    final db = await AppDatabase.instance.database;

    // Select accounts of type asset (1), liability (2), or investment (15)
    final result = await db.rawQuery('''
    SELECT 
      a.id,
      a.name,
      a.type,
      a.currency_id,
      IFNULL(SUM(CAST(s.numerator AS INTEGER)), 0) as total_num,
      IFNULL(MAX(CAST(s.denominator AS INTEGER)), 1) as denom
    FROM accounts a
    LEFT JOIN splits s
      ON a.id = s.account_id
    WHERE a.type IN ('1', '2', '15')
    AND a.closed = 0
    GROUP BY a.id
  ''');

    return result.map((row) {
      return AccountWithBalanceRow(
        id: row['id'] as String,
        name: row['name'] as String,
        type: row['type'] as String,
        currencyId: row['currency_id'] as String,
        balance: Money(
          BigInt.parse(row['total_num'].toString()),
          BigInt.parse(row['denom'].toString()),
        ),
      );
    }).toList();
  }
}
