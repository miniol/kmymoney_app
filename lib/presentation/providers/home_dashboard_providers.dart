import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/account_dao.dart';
import '../../data/database/db_change_notifier.dart';
import '../../data/database/models/account_type.dart';
import '../../data/database/models/account_with_balance_row.dart';
import '../../data/database/models/schedule_with_details_row.dart';
import '../../data/database/schedule_dao.dart';

final soonestSchedulesProvider = StreamProvider<List<ScheduleWithDetailsRow>>((
  ref,
) async* {
  final dao = ScheduleDao();

  yield await dao.getSoonestSchedules(limit: 5);

  await for (final _ in DbChangeNotifier.instance.stream) {
    yield await dao.getSoonestSchedules(limit: 5);
  }
});

final preferredAccountsProvider = StreamProvider<List<AccountWithBalanceRow>>((
  ref,
) async* {
  final dao = AccountDao();

  final visibleTypes =
      AccountType.values.where((t) => t != AccountType.unknown).toSet();

  yield await dao.getAccountsWithBalances(
    visibleTypes: visibleTypes,
    showClosed: false,
    preferredOnly: true,
  );

  await for (final _ in DbChangeNotifier.instance.stream) {
    yield await dao.getAccountsWithBalances(
      visibleTypes: visibleTypes,
      showClosed: false,
      preferredOnly: true,
    );
  }
});
