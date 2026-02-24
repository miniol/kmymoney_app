enum AccountType {
  asset,
  liability,
  income,
  expense,
  equity,
  investment,
  unknown,
}

extension AccountTypeX on AccountType {
  static AccountType fromKmyType(String value) {
    switch (value) {
      case '1':
        return AccountType.asset;
      case '2':
        return AccountType.liability;
      case '10':
        return AccountType.income;
      case '13':
        return AccountType.expense;
      case '12':
        return AccountType.equity;
      case '15':
        return AccountType.investment;
      default:
        return AccountType.unknown;
    }
  }

  String get dbValue {
    switch (this) {
      case AccountType.asset:
        return '1';
      case AccountType.liability:
        return '2';
      case AccountType.income:
        return '10';
      case AccountType.expense:
        return '13';
      case AccountType.equity:
        return '12';
      case AccountType.investment:
        return '15';
      case AccountType.unknown:
        return '0';
    }
  }
}
