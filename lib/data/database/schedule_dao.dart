import 'package:sqflite/sqflite.dart';

import '../../domain/models/money.dart';
import '../../domain/models/schedule.dart';
import 'app_database.dart';
import 'db_change_notifier.dart';
import 'models/schedule_with_details_row.dart';

class ScheduleDao {
  Future<void> insertSchedules(List<Schedule> schedules) async {
    final db = await AppDatabase.instance.database;

    final batch = db.batch();

    for (final s in schedules) {
      batch.insert('schedules', {
        'id': s.id,
        'group_key': s.group.dbValue,
        'name': s.name,
        'account_id': s.accountId,
        'currency_id': s.currencyId,
        'payee': s.payee,
        'frequency': s.frequency,
        'payment_method': s.paymentMethod,
        'next_due_date': s.nextDueDate.toIso8601String(),
        'amount_num': s.amount.numerator.toString(),
        'amount_denom': s.amount.denominator.toString(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
    DbChangeNotifier.instance.notify();
  }

  Future<void> clear() async {
    final db = await AppDatabase.instance.database;
    await db.delete('schedules');
    DbChangeNotifier.instance.notify();
  }

  Future<List<ScheduleWithDetailsRow>> getSchedules() async {
    final db = await AppDatabase.instance.database;

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day).toIso8601String();

    final rows = await db.rawQuery(
      '''
      SELECT
        s.id,
        s.group_key,
        s.name,
        s.account_id,
        s.currency_id,
        IFNULL(p.name, s.payee) as payee,
        s.frequency,
        s.payment_method,
        s.next_due_date,
        s.amount_num,
        s.amount_denom,
        IFNULL(a.name, '') as account_name,
        IFNULL(a.currency_id, s.currency_id) as account_currency_id
      FROM schedules s
      LEFT JOIN accounts a ON a.id = s.account_id
      LEFT JOIN payees p ON p.id = s.payee
      WHERE s.next_due_date >= ?
      ORDER BY s.next_due_date ASC
    ''',
      [todayStart],
    );

    return rows.map((r) {
      return ScheduleWithDetailsRow(
        id: r['id'] as String,
        group: ScheduleGroupX.fromString(r['group_key'] as String),
        name: r['name'] as String,
        accountName: r['account_name'] as String,
        currencyId: r['account_currency_id'] as String,
        amount: Money(
          BigInt.parse(r['amount_num'].toString()),
          BigInt.parse(r['amount_denom'].toString()),
        ),
        nextDueDate:
            DateTime.tryParse(r['next_due_date'] as String) ??
            DateTime(1970, 1, 1),
        payee: r['payee'] as String,
        frequency: r['frequency'] as String,
        paymentMethod: r['payment_method'] as String,
      );
    }).toList();
  }
}
