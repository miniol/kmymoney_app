import '../../domain/repositories/kmy_repository.dart';
import '../kmy_file_loader.dart';
import '../kmy_parser.dart';
import '../database/account_dao.dart';
import '../database/payee_dao.dart';
import '../database/schedule_dao.dart';
import '../database/transaction_dao.dart';

class KmyRepositoryImpl implements KmyRepository {
  final _accountDao = AccountDao();
  final _payeeDao = PayeeDao();
  final _scheduleDao = ScheduleDao();
  final _transactionDao = TransactionDao();

  @override
  Future<void> loadFromPath(String path) async {
    final xmlString = await KmyFileLoader.load(path);

    final parser = KmyParser(xmlString);

    final accounts = parser.parseAccounts();
    final payees = parser.parsePayees();
    final transactions = parser.parseTransactions();
    final schedules = parser.parseSchedules();

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
