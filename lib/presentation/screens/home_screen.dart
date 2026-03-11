import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/models/account_with_balance_row.dart';
import '../../data/database/models/schedule_with_details_row.dart';
import '../providers/home_dashboard_providers.dart';
import '../providers/kmy_file_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _currencySymbol(String currencyId) {
    final code = currencyId.trim();

    switch (code) {
      case 'EUR':
        return '€';
      case 'USD':
        return r'$';
      case 'GBP':
        return '£';
      case 'PLN':
        return 'zł';
      default:
        return code.isEmpty ? '' : code;
    }
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  Widget _scheduleTile(BuildContext context, ScheduleWithDetailsRow item) {
    return ListTile(
      title: Text(item.name),
      subtitle: Text(
        '${item.accountName}  •  ${_formatDate(item.nextDueDate)}',
      ),
      trailing: Text(
        '${_currencySymbol(item.currencyId)} ${item.amount.toDecimal()}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _accountTile(BuildContext context, AccountWithBalanceRow item) {
    return ListTile(
      title: Text(
        item.name,
        style: TextStyle(
          fontWeight: item.isFavorite ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(item.id),
      trailing: Text(
        '${_currencySymbol(item.currencyId)} ${item.balance.toDecimal()}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soonestSchedulesAsync = ref.watch(soonestSchedulesProvider);
    final preferredAccountsAsync = ref.watch(preferredAccountsProvider);
    final importState = ref.watch(kmyFileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      floatingActionButton: FloatingActionButton(
        onPressed: importState.isLoading
            ? null
            : () async {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.any,
                );

                if (result != null && result.files.single.path != null) {
                  final path = result.files.single.path!;
                  await ref.read(kmyFileProvider.notifier).loadFile(path);
                }
              },
        child: const Icon(Icons.folder_open),
      ),
      body: ListView(
        children: [
          if (importState.hasError)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(importState.error.toString()),
            ),
          _sectionHeader(context, 'Soonest schedules'),
          soonestSchedulesAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('No schedules'),
                );
              }

              return Column(
                children: items.map((e) => _scheduleTile(context, e)).toList(),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(err.toString()),
            ),
          ),
          _sectionHeader(context, 'Preferred accounts'),
          preferredAccountsAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('No preferred accounts'),
                );
              }

              return Column(
                children: items.map((e) => _accountTile(context, e)).toList(),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(err.toString()),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
