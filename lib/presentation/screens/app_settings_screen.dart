// Copyright (c) 2026 by Zafado.pl
//
// This file is part of kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// App Settings Screen
//
// Settings screen for application preferences.
// Provides theme, locale, and data file configuration.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_settings_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/kmy_local_path_provider.dart';

/// Settings screen for application preferences and data management.
///
/// This screen provides UI controls for configuring application
/// settings including theme mode, language preferences, and
/// KMyMoney data file selection. It uses Riverpod providers
/// for reactive state management and persists user preferences.
///
/// Features:
/// - Theme mode selection (system, light, dark)
/// - Language configuration
/// - KMyMoney file picker with persistent storage
/// - Clear configured data file option
/// - Real-time state updates with loading indicators
class AppSettingsScreen extends ConsumerWidget {
  /// Creates the app settings screen widget.
  const AppSettingsScreen({super.key});

  /// Builds the settings screen UI with theme, language, and data options.
  ///
  /// Constructs a settings screen with sections for:
  /// - Look & Feel: Theme mode selection (system, light, dark)
  /// - Data: KMyMoney file picker and clear option
  /// - Language: Locale selection dropdown
  ///
  /// Uses Riverpod providers for reactive state management:
  /// - [appSettingsProvider] for theme and locale settings
  /// - [kmyLocalPathProvider] for data file path
  ///
  /// Parameters:
  /// - [context]: Build context for widget creation
  /// - [ref]: WidgetRef for accessing providers
  ///
  /// Returns a [Scaffold] with settings controls in a [ListView].
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const ListTile(title: Text('Look')),
          ListTile(
            title: const Text('Color mode'),
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              onChanged: (value) {
                if (value == null) return;
                notifier.setThemeMode(value);
              },
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System'),
                ),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
            ),
          ),

          const ListTile(title: Text('Data')),

          Consumer(
            builder: (context, ref, _) {
              final localPathAsync = ref.watch(kmyLocalPathProvider);
              final notifier = ref.read(kmyLocalPathProvider.notifier);

              final subtitle = localPathAsync.when(
                data: (path) => path ?? 'Not configured',
                loading: () => 'Loading...',
                error: (e, _) => e.toString(),
              );

              return ListTile(
                title: const Text('KmyMoney data file (.kmy)'),
                subtitle: Text(subtitle),
                trailing: IconButton(
                  icon: const Icon(Icons.folder_open),
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.any,
                    );
                    final path = result?.files.single.path;
                    if (path == null) return;
                    await notifier.setPath(path);
                  },
                ),
              );
            },
          ),

          ListTile(
            title: const Text('Clear configured file'),
            trailing: const Icon(Icons.delete_outline),
            onTap: () async {
              await ref.read(kmyLocalPathProvider.notifier).setPath(null);
            },
          ),

          const Divider(),

          ListTile(
            title: const Text('Language'),
            trailing: DropdownButton<Locale>(
              value: settings.locale,
              onChanged: (value) {
                if (value == null) return;
                notifier.setLocale(value);
              },
              items: const [
                DropdownMenuItem<Locale>(
                  value: Locale('en'),
                  child: Text('English'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
