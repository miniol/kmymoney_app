import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/models/schedule_with_details_row.dart';
import '../../domain/models/schedule.dart';
import '../providers/schedule_list_provider.dart';

class SchedulesScreen extends ConsumerWidget {
  const SchedulesScreen({super.key});

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

  String _titleForGroup(ScheduleGroup group) {
    switch (group) {
      case ScheduleGroup.bills:
        return 'Bills';
      case ScheduleGroup.deposits:
        return 'Deposits';
      case ScheduleGroup.loans:
        return 'Loans';
      case ScheduleGroup.transfers:
        return 'Transfers';
    }
  }

  Widget _groupHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  Widget _scheduleTile(BuildContext context, ScheduleWithDetailsRow item) {
    return ExpansionTile(
      title: Text(item.name),
      subtitle: Text(
        '${item.accountName}  •  Next: ${_formatDate(item.nextDueDate)}',
      ),
      trailing: Text(
        '${_currencySymbol(item.currencyId)} ${item.amount.toDecimal()}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      children: [
        ListTile(title: const Text('Payee'), trailing: Text(item.payee)),
        ListTile(
          title: const Text('Frequency'),
          trailing: Text(item.frequency),
        ),
        ListTile(
          title: const Text('Payment method'),
          trailing: Text(item.paymentMethod),
        ),
      ],
    );
  }

  Widget _groupSection(
    BuildContext context, {
    required ScheduleGroup group,
    required List<ScheduleWithDetailsRow> all,
  }) {
    final items = all.where((e) => e.group == group).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _groupHeader(context, _titleForGroup(group)),
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('No schedules'),
          )
        else
          ...items.map((e) => _scheduleTile(context, e)),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulesAsync = ref.watch(scheduleListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Schedules')),
      body: schedulesAsync.when(
        data: (items) {
          return ListView(
            children: [
              _groupSection(context, group: ScheduleGroup.bills, all: items),
              _groupSection(context, group: ScheduleGroup.deposits, all: items),
              _groupSection(context, group: ScheduleGroup.loans, all: items),
              _groupSection(
                context,
                group: ScheduleGroup.transfers,
                all: items,
              ),
              const SizedBox(height: 12),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(err.toString())),
      ),
    );
  }
}
