import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/models/account_type.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(accountFilterProvider);
    final notifier = ref.read(accountFilterProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Account Filters')),
      body: ListView(
        children: [
          const ListTile(title: Text('Account Types')),
          ...AccountType.values.map((type) {
            if (type == AccountType.unknown) {
              return const SizedBox();
            }

            return CheckboxListTile(
              title: Text(type.name),
              value: settings.visibleTypes.contains(type),
              onChanged: (_) => notifier.toggleType(type),
            );
          }),
          const Divider(),
          SwitchListTile(
            title: const Text('Show Closed'),
            value: settings.showClosed,
            onChanged: (_) => notifier.toggleShowClosed(),
          ),
        ],
      ),
    );
  }
}
