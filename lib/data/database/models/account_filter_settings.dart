import 'account_type.dart';

class AccountFilterSettings {
  final Set<AccountType> visibleTypes;
  final bool showClosed;

  const AccountFilterSettings({
    required this.visibleTypes,
    required this.showClosed,
  });

  factory AccountFilterSettings.defaultSettings() {
    return const AccountFilterSettings(
      visibleTypes: {AccountType.asset, AccountType.liability},
      showClosed: false,
    );
  }

  AccountFilterSettings copyWith({
    Set<AccountType>? visibleTypes,
    bool? showClosed,
  }) {
    return AccountFilterSettings(
      visibleTypes: visibleTypes ?? this.visibleTypes,
      showClosed: showClosed ?? this.showClosed,
    );
  }
}
