import 'package:sqflite/sqflite.dart';

import '../../domain/models/payee.dart';
import 'app_database.dart';
import 'db_change_notifier.dart';

class PayeeDao {
  Future<void> insertPayees(List<Payee> payees) async {
    final db = await AppDatabase.instance.database;

    final batch = db.batch();

    for (final p in payees) {
      batch.insert('payees', {
        'id': p.id,
        'name': p.name,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
    DbChangeNotifier.instance.notify();
  }

  Future<void> clear() async {
    final db = await AppDatabase.instance.database;
    await db.delete('payees');
    DbChangeNotifier.instance.notify();
  }
}
