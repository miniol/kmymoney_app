import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/account_dao.dart';
import '../../data/database/db_change_notifier.dart';
import '../../data/database/models/account_with_balance_row.dart';
// import '../../data/database/models/account_type.dart';
import 'settings_provider.dart';

final accountListProvider = StreamProvider<List<AccountWithBalanceRow>>((
  ref,
) async* {
  final accountDao = AccountDao();

  yield* _watchAccounts(ref, accountDao);
});

Stream<List<AccountWithBalanceRow>> _watchAccounts(
  Ref ref,
  AccountDao accountDao,
) async* {
  final settings = ref.watch(accountFilterProvider);

  yield await accountDao.getAccountsWithBalances(
    visibleTypes: settings.visibleTypes,
    showClosed: settings.showClosed,
    preferredOnly: settings.preferredOnly,
  );

  await for (final _ in DbChangeNotifier.instance.stream) {
    final updatedSettings = ref.read(accountFilterProvider);

    yield await accountDao.getAccountsWithBalances(
      visibleTypes: updatedSettings.visibleTypes,
      showClosed: updatedSettings.showClosed,
      preferredOnly: updatedSettings.preferredOnly,
    );
  }
}
