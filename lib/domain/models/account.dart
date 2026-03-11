class Account {
  final String id;
  final String name;
  final String type;
  final String currencyId;
  final bool closed;
  final bool preferred;

  Account({
    required this.id,
    required this.name,
    required this.type,
    required this.currencyId,
    required this.closed,
    this.preferred = false,
  });
}
