import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/kmy_file_provider.dart';
import '../providers/account_list_provider.dart';
import 'account_transactions_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'settings_screen.dart';

// import '../../domain/models/money.dart';
// import '../../data/database/models/account_with_balance_row.dart';

class AccountListScreen extends ConsumerWidget {
  const AccountListScreen({super.key});

  // String _formatMoney(Money money) {
  //   return money.toDecimal().toString();
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountListAsync = ref.watch(accountListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await FilePicker.platform.pickFiles(
            type: FileType.any,
          );

          if (result != null && result.files.single.path != null) {
            final path = result.files.single.path!;

            // print('Selected file: $path');

            ref.read(kmyFileProvider.notifier).loadFile(path);
          }
        },
        child: const Icon(Icons.folder_open),
      ),
      body: accountListAsync.when(
        data: (accounts) {
          return ListView.builder(
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];

              return ListTile(
                title: Text(account.name),
                subtitle: Text(account.type),
                trailing: Text(
                  account.balance.toDecimal().toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AccountTransactionsScreen(
                        accountId: account.id,
                        accountName: account.name,
                      ),
                    ),
                  );
                },
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
