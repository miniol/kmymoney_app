import '../../domain/repositories/kmy_repository.dart';
import '../kmy_file_loader.dart';
import '../kmy_parser.dart';
import '../database/account_dao.dart';
import '../database/transaction_dao.dart';

class KmyRepositoryImpl implements KmyRepository {
  final _accountDao = AccountDao();
  final _transactionDao = TransactionDao();

  @override
  Future<void> loadFromPath(String path) async {
    final xmlString = await KmyFileLoader.load(path);

    final parser = KmyParser(xmlString);

    final accounts = parser.parseAccounts();
    final transactions = parser.parseTransactions();

    // Clear old data
    await _transactionDao.clear();
    await _accountDao.clear();

    // Insert fresh data
    await _accountDao.insertAccounts(accounts);
    await _transactionDao.insertTransactions(transactions);
  }
}
