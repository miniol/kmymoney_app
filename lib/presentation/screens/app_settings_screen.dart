// Copyright (c) 2026 by Zafado.pl
//
// This file is part of kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// App Settings Screen
//
// Settings screen for application preferences.
// Provides theme, locale, and data file configuration.

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/cloud/cloud_file_backend.dart';
import '../providers/app_settings_provider.dart';
import '../providers/cloud_sync_settings_provider.dart';
import '../providers/kmy_local_path_provider.dart';
import '../providers/cloud_backend_provider.dart';

class AppSettingsScreen extends ConsumerStatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  ConsumerState<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends ConsumerState<AppSettingsScreen> {
  final TextEditingController _oneDriveClientIdController =
      TextEditingController();

  @override
  void dispose() {
    _oneDriveClientIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);

    final cloudSettingsAsync = ref.watch(cloudSyncSettingsProvider);
    final cloudSettingsNotifier = ref.read(cloudSyncSettingsProvider.notifier);

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
              final localPathNotifier = ref.read(kmyLocalPathProvider.notifier);

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
                    await localPathNotifier.setPath(path);
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
          const ListTile(title: Text('Cloud sync')),
          cloudSettingsAsync.when(
            data: (cloudSettings) {
              return ListTile(
                title: const Text('Provider'),
                trailing: DropdownButton<CloudProviderType>(
                  value: cloudSettings.provider,
                  onChanged: (value) async {
                    if (value == null) return;
                    await cloudSettingsNotifier.setProvider(value);
                  },
                  items: const [
                    DropdownMenuItem(
                      value: CloudProviderType.googleDrive,
                      child: Text('Google Drive'),
                    ),
                    DropdownMenuItem(
                      value: CloudProviderType.oneDrive,
                      child: Text('OneDrive'),
                    ),
                  ],
                ),
              );
            },
            loading: () => const ListTile(
              title: Text('Provider'),
              subtitle: Text('Loading...'),
            ),
            error: (e, _) => ListTile(
              title: const Text('Provider'),
              subtitle: Text(e.toString()),
            ),
          ),
          cloudSettingsAsync.when(
            data: (cloudSettings) {
              final desired = cloudSettings.oneDriveClientId ?? '';
              if (_oneDriveClientIdController.text != desired) {
                _oneDriveClientIdController.text = desired;
              }
              return Column(
                children: [
                  ListTile(
                    title: const Text('Account'),
                    subtitle: Text(
                      cloudSettings.provider == CloudProviderType.googleDrive
                          ? 'Google Drive'
                          : 'OneDrive',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () async {
                            final backend = ref.read(
                              activeCloudBackendProvider,
                            );

                            if (backend == null) {
                              if (!context.mounted) return;
                              showDialog<void>(
                                context: context,
                                builder: (_) => const AlertDialog(
                                  title: Text('Cloud backend not ready'),
                                  content: Text(
                                    'For OneDrive, set OneDrive Client ID in Settings first.',
                                  ),
                                ),
                              );
                              return;
                            }
                            try {
                              await backend.signIn();
                            } catch (e) {
                              if (!context.mounted) return;
                              showDialog<void>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text('Sign-in failed'),
                                  content: Text(e.toString()),
                                ),
                              );
                              return;
                            }
                          },
                          child: const Text('Connect'),
                        ),
                        TextButton(
                          onPressed: () async {
                            final backend = ref.read(
                              activeCloudBackendProvider,
                            );
                            if (backend == null) return;

                            try {
                              await backend.signOut();
                            } catch (e) {
                              if (!context.mounted) return;
                              showDialog<void>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text('Sign-out failed'),
                                  content: Text(e.toString()),
                                ),
                              );
                              return;
                            }
                          },
                          child: const Text('Disconnect'),
                        ),
                      ],
                    ),
                  ),
                  if (cloudSettings.provider == CloudProviderType.oneDrive)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'OneDrive Client ID',
                        ),
                        controller: _oneDriveClientIdController,
                        onSubmitted: (v) =>
                            cloudSettingsNotifier.setOneDriveClientId(v),
                      ),
                    ),
                  ListTile(
                    title: const Text('Remote .kmy file'),
                    subtitle: Text(
                      cloudSettings.remoteFileName ??
                          cloudSettings.remoteFileId ??
                          'Not selected',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.cloud),
                      onPressed: () async {
                        final backend = ref.read(activeCloudBackendProvider);

                        if (backend == null) {
                          if (!context.mounted) return;
                          showDialog<void>(
                            context: context,
                            builder: (_) => const AlertDialog(
                              title: Text('Cloud backend not ready'),
                              content: Text(
                                'For OneDrive, set OneDrive Client ID in Settings first.',
                              ),
                            ),
                          );
                          return;
                        }

                        try {
                          await backend.signIn();
                        } catch (e) {
                          if (!context.mounted) return;
                          showDialog<void>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('Sign-in failed'),
                              content: Text(e.toString()),
                            ),
                          );
                          return;
                        }

                        final files = await backend.listKmyFiles(pageSize: 50);
                        if (!context.mounted) return;

                        final selected = await showDialog<RemoteFileInfo>(
                          context: context,
                          builder: (context) {
                            return SimpleDialog(
                              title: const Text('Select .kmy file'),
                              children: files
                                  .map(
                                    (f) => SimpleDialogOption(
                                      onPressed: () =>
                                          Navigator.pop(context, f),
                                      child: Text(
                                        f.name.isEmpty ? f.id : f.name,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                        );

                        if (selected == null) return;

                        await cloudSettingsNotifier.setRemoteFile(
                          id: selected.id,
                          name: selected.name,
                        );
                      },
                    ),
                  ),
                  const Divider(),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
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
