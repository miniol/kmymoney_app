// Copyright (c) 2026 by Zafado.pl
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// Home Screen
//
// Main dashboard screen for the KMyMoney app.
// Displays account summaries and upcoming schedules.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kmymoney_app/presentation/providers/kmy_local_path_provider.dart';
import '../../data/database/models/account_with_balance_row.dart';
import '../../data/database/models/schedule_with_details_row.dart';
import '../providers/home_dashboard_providers.dart';
import '../providers/kmy_file_provider.dart';
import 'app_settings_screen.dart';

/// Main dashboard screen for the KMyMoney application.
///
/// This screen provides an overview of the user's financial data
/// including preferred account balances and upcoming scheduled
/// transactions. It also provides file loading functionality.
///
/// Features:
/// - Preferred accounts with balances
/// - Upcoming scheduled transactions
/// - File picker for KMyMoney files
/// - Loading and error state handling
class HomeScreen extends ConsumerWidget {
  /// Creates the home screen widget.
  const HomeScreen({super.key});

  /// Converts currency code to appropriate symbol.
  ///
  /// Maps common currency codes to their symbols for display.
  /// Falls back to the currency code if no symbol is available.
  ///
  /// Parameters:
  /// - [currencyId]: ISO currency code (e.g., 'USD', 'EUR')
  ///
  /// Returns currency symbol or code as string.
  String _currencySymbol(String currencyId) {
    // Clean and normalize currency code
    final code = currencyId.trim();

    // Map common currencies to their symbols
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
        // Return code or empty string if no code provided
        return code.isEmpty ? '' : code;
    }
  }

  /// Formats DateTime for display in the UI.
  ///
  /// Converts a DateTime object to a user-friendly string
  /// format suitable for displaying dates in the interface.
  ///
  /// Parameters:
  /// - [date]: DateTime to format
  ///
  /// Returns formatted date string.
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
    final localPathAsync = ref.watch(kmyLocalPathProvider);
    final localPath = localPathAsync.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      floatingActionButton: FloatingActionButton(
        onPressed: importState.isLoading || localPathAsync.isLoading
            ? null
            : () async {
                if (localPath == null || localPath.trim().isEmpty) {
                  final openSettings = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('No data file configured'),
                        content: const Text(
                          'Configure the local .kmy file path in Settings first.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Open settings'),
                          ),
                        ],
                      );
                    },
                  );

                  if (openSettings == true && context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AppSettingsScreen(),
                      ),
                    );
                  }
                  return;
                }
                await ref.read(kmyFileProvider.notifier).loadFile(localPath);
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
