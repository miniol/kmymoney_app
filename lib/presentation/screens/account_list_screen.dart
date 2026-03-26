// Copyright (c) 2026 by Zafado.pl
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// Account List Screen
//
// Screen displaying list of financial accounts.
// Provides filtering, navigation, and file operations.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/kmy_file_provider.dart';
import '../providers/account_list_provider.dart';
import 'account_transactions_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'settings_screen.dart';
import '../../data/database/models/account_type.dart';

// import '../../domain/models/money.dart';
// import '../../data/database/models/account_with_balance_row.dart';

/// Screen displaying a filtered list of financial accounts.
///
/// This screen shows accounts with their balances, allows filtering
/// by account type and status, provides navigation to transaction
/// details, and includes file loading functionality.
///
/// Features:
/// - Account list with balances
/// - Account type filtering
/// - Navigation to transaction details
/// - File picker for KMyMoney files
/// - Loading and error state handling
class AccountListScreen extends ConsumerWidget {
  /// Creates the account list screen widget.
  const AccountListScreen({super.key});

  /// Maps KMyMoney account type to appropriate icon.
  ///
  /// Converts KMyMoney string account types to Flutter icons
  /// for visual representation in the UI. Each account type
  /// gets a meaningful icon that represents its purpose.
  ///
  /// Parameters:
  /// - [kmyType]: KMyMoney account type string
  ///
  /// Returns appropriate [IconData] for the account type.
  IconData _iconForAccountType(String kmyType) {
    // Convert KMyMoney type to enum and map to icon
    final type = AccountTypeX.fromKmyType(kmyType);

    switch (type) {
      case AccountType.asset:
        return Icons.account_balance_wallet;
      case AccountType.liability:
        return Icons.credit_card;
      case AccountType.income:
        return Icons.trending_up;
      case AccountType.expense:
        return Icons.trending_down;
      case AccountType.equity:
        return Icons.pie_chart;
      case AccountType.investment:
        return Icons.show_chart;
      case AccountType.unknown:
        return Icons.account_balance;
    }
  }

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
                leading: Icon(_iconForAccountType(account.type)),
                title: Text(
                  account.name,
                  style: TextStyle(
                    fontWeight: account.isFavorite
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                trailing: Text(
                  '${_currencySymbol(account.currencyId)} ${account.balance.toDecimal()}',
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
