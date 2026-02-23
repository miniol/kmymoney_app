import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/account_dao.dart';
import '../../data/database/db_change_notifier.dart';
import '../../data/database/models/account_with_balance_row.dart';

final accountListProvider = StreamProvider<List<AccountWithBalanceRow>>((
  ref,
) async* {
  final accountDao = AccountDao();

  // Initial load
  yield await accountDao.getAccountsWithBalances();

  // Reactive updates
  await for (final _ in DbChangeNotifier.instance.stream) {
    yield await accountDao.getAccountsWithBalances();
  }
});
