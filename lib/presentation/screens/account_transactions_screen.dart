import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/account_transactions_provider.dart';
import '../../domain/models/ledger_transaction.dart';
import '../../domain/models/money.dart';

class AccountTransactionsScreen extends ConsumerWidget {
  final String accountId;
  final String accountName;

  const AccountTransactionsScreen({
    super.key,
    required this.accountId,
    required this.accountName,
  });

  String _formatMoney(Money money) {
    return money.toDecimal().toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(accountTransactionsProvider(accountId));

    return Scaffold(
      appBar: AppBar(title: Text(accountName)),
      body: transactionsAsync.when(
        data: (transactions) {
          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final LedgerTransaction tx = transactions[index];

              final split = tx.splits.first;

              return ListTile(
                title: Text('Transaction ${tx.id}'),
                subtitle: Text(tx.date.toString()),
                trailing: Text(_formatMoney(split.value)),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text(err.toString())),
      ),
    );
  }
}
