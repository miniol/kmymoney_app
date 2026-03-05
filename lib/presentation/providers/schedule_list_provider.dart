import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/db_change_notifier.dart';
import '../../data/database/schedule_dao.dart';
import '../../data/database/models/schedule_with_details_row.dart';

final scheduleListProvider = StreamProvider<List<ScheduleWithDetailsRow>>((
  ref,
) async* {
  final dao = ScheduleDao();

  yield await dao.getSchedules();

  await for (final _ in DbChangeNotifier.instance.stream) {
    yield await dao.getSchedules();
  }
});
