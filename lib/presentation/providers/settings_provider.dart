import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/models/account_filter_settings.dart';
import '../../data/database/models/account_type.dart';

class AccountFilterNotifier extends StateNotifier<AccountFilterSettings> {
  AccountFilterNotifier() : super(AccountFilterSettings.defaultSettings());

  void toggleType(AccountType type) {
    final current = Set<AccountType>.from(state.visibleTypes);

    if (current.contains(type)) {
      current.remove(type);
    } else {
      current.add(type);
    }

    state = state.copyWith(visibleTypes: current);
  }

  void toggleShowClosed() {
    state = state.copyWith(showClosed: !state.showClosed);
  }

  void togglePreferredOnly() {
    state = state.copyWith(preferredOnly: !state.preferredOnly);
  }
}

final accountFilterProvider =
    StateNotifierProvider<AccountFilterNotifier, AccountFilterSettings>(
      (ref) => AccountFilterNotifier(),
    );
