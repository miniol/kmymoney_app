// Copyright (c) 2026 by Zafado.pl
//
// This file is part of kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// Cloud Sync Settings Provider
//
// Riverpod provider for cloud synchronization settings.
// Manages cloud provider selection and remote file configuration.

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enumeration of supported cloud storage providers.
///
/// Defines the available cloud storage services that can be used
/// for KMyMoney file synchronization. Currently supports Google Drive
/// and OneDrive with potential for future expansion.
enum CloudProviderType { googleDrive, oneDrive }

/// Immutable model for cloud synchronization settings.
///
/// This class holds the configuration for cloud sync including
/// the selected cloud provider and remote file information.
/// It supports JSON serialization for persistent storage.
///
/// Properties:
/// - [provider]: The selected cloud storage service
/// - [remoteFileId]: Unique identifier for the remote file
/// - [remoteFileName]: Name of the remote file in cloud storage
/// - [oneDriveClientId]: Client ID for OneDrive authentication
/// - [lastRemoteVersion]: Last known version of the remote file
/// - [lastLocalHash]: Last known hash of the local file
/// - [lastSyncTimestamp]: Timestamp of the last sync
class CloudSyncSettings {
  final CloudProviderType provider;
  final String? remoteFileId;
  final String? remoteFileName;
  final String? oneDriveClientId;
  final String? lastRemoteVersion;
  final String? lastLocalHash;
  final int? lastSyncTimestamp;

  /// Creates cloud sync settings with specified configuration.
  ///
  /// Parameters:
  /// - [provider]: The cloud storage service to use
  /// - [remoteFileId]: Unique identifier for the remote file (nullable)
  /// - [remoteFileName]: Name of the remote file (nullable)
  /// - [oneDriveClientId]: Client ID for OneDrive authentication (nullable)
  /// - [lastRemoteVersion]: Last known version of the remote file (nullable)
  /// - [lastLocalHash]: Last known hash of the local file (nullable)
  /// - [lastSyncTimestamp]: Timestamp of the last sync (nullable)
  const CloudSyncSettings({
    required this.provider,
    required this.remoteFileId,
    required this.remoteFileName,
    required this.oneDriveClientId,
    required this.lastRemoteVersion,
    required this.lastLocalHash,
    required this.lastSyncTimestamp,
  });

  /// Creates default cloud sync settings.
  ///
  /// Returns settings with Google Drive as the default provider
  /// and no remote file configured. Used as the initial state
  /// when no preferences are saved.
  ///
  /// Returns default [CloudSyncSettings] instance.
  factory CloudSyncSettings.defaults() => const CloudSyncSettings(
    provider: CloudProviderType.googleDrive,
    remoteFileId: null,
    remoteFileName: null,
    oneDriveClientId: null,
    lastRemoteVersion: null,
    lastLocalHash: null,
    lastSyncTimestamp: null,
  );

  /// Creates a copy of this settings with updated values.
  ///
  /// Provides immutable state updates by creating a new
  /// instance with specified fields changed. Unspecified
  /// fields retain their original values.
  ///
  /// Parameters:
  /// - [provider]: New cloud provider (optional)
  /// - [remoteFileId]: New remote file ID (optional)
  /// - [remoteFileName]: New remote file name (optional)
  /// - [oneDriveClientId]: New OneDrive client ID (optional)
  ///
  /// Returns new [CloudSyncSettings] with updated values.
  CloudSyncSettings copyWith({
    CloudProviderType? provider,
    String? remoteFileId,
    String? remoteFileName,
    String? oneDriveClientId,
    String? lastRemoteVersion,
    String? lastLocalHash,
    int? lastSyncTimestamp,
  }) {
    return CloudSyncSettings(
      provider: provider ?? this.provider,
      remoteFileId: remoteFileId,
      remoteFileName: remoteFileName,
      oneDriveClientId: oneDriveClientId,
      lastRemoteVersion: lastRemoteVersion ?? this.lastRemoteVersion,
      lastLocalHash: lastLocalHash ?? this.lastLocalHash,
      lastSyncTimestamp: lastSyncTimestamp ?? this.lastSyncTimestamp,
    );
  }

  /// Converts settings to JSON for serialization.
  ///
  /// Serializes the settings object to a Map that can be
  /// stored in SharedPreferences or other persistent storage.
  ///
  /// Returns a [Map<String, dynamic>] representation of the settings.
  Map<String, dynamic> toJson() => {
    'provider': provider.name,
    'remoteFileId': remoteFileId,
    'remoteFileName': remoteFileName,
    'oneDriveClientId': oneDriveClientId,
    'lastRemoteVersion': lastRemoteVersion,
    'lastLocalHash': lastLocalHash,
    'lastSyncTimestamp': lastSyncTimestamp,
  };

  /// Creates settings from JSON data.
  ///
  /// Deserializes settings from a Map, with error handling
  /// for invalid or missing data. Falls back to Google Drive
  /// provider if the provider name is not recognized.
  ///
  /// Parameters:
  /// - [json]: Map containing serialized settings data
  ///
  /// Returns a [CloudSyncSettings] instance.
  static CloudSyncSettings fromJson(Map<String, dynamic> json) {
    final providerName = (json['provider'] as String?) ?? 'googleDrive';
    final provider = CloudProviderType.values.firstWhere(
      (p) => p.name == providerName,
      orElse: () => CloudProviderType.googleDrive,
    );
    // Backward compatibility: remoteFileId was previously called remoteFieldId
    final remoteFileId =
        (json['remoteFileId'] as String?) ?? (json['remoteFieldId'] as String?);
    return CloudSyncSettings(
      provider: provider,
      remoteFileId: remoteFileId,
      remoteFileName: json['remoteFileName'] as String?,
      oneDriveClientId: json['oneDriveClientId'] as String?,
      lastRemoteVersion: json['lastRemoteVersion'] as String?,
      lastLocalHash: json['lastLocalHash'] as String?,
      lastSyncTimestamp: json['lastSyncTimestamp'] as int?,
    );
  }
}

/// Riverpod AsyncNotifier for managing cloud sync settings.
///
/// This notifier handles persistent storage of cloud synchronization
/// settings using SharedPreferences with JSON serialization. It provides
/// methods to update the cloud provider and remote file configuration
/// with proper async state management.
///
/// Features:
/// - Persistent storage using SharedPreferences
/// - JSON serialization/deserialization
/// - Async state management with error handling
/// - Provider selection and remote file configuration
/// - Graceful fallback to defaults on errors
///
/// State management:
/// - Returns [CloudSyncSettings] with current configuration
/// - Provides AsyncLoading state during updates
/// - Handles JSON parsing errors with fallback to defaults
class CloudSyncSettingsNotifier extends AsyncNotifier<CloudSyncSettings> {
  /// SharedPreferences key for storing cloud sync settings.
  static const _key = 'cloud_sync_settings_v1';

  /// Builds the initial state by loading stored settings from SharedPreferences.
  ///
  /// Retrieves the stored cloud sync settings from persistent storage,
  /// deserializes JSON data, and handles errors gracefully. Returns
  /// default settings if no data is stored or if parsing fails.
  ///
  /// Returns:
  /// - [CloudSyncSettings] with stored configuration, or
  /// - Default settings if no valid data exists
  @override
  Future<CloudSyncSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.trim().isEmpty) return CloudSyncSettings.defaults();

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return CloudSyncSettings.fromJson(decoded);
    } catch (_) {
      return CloudSyncSettings.defaults();
    }
  }

  /// Updates the cloud provider and persists the change.
  ///
  /// Changes the cloud storage service while preserving other
  /// settings. Updates the state and persists the new configuration
  /// to SharedPreferences.
  ///
  /// Parameters:
  /// - [provider]: The new cloud provider to use
  Future<void> setProvider(CloudProviderType provider) async {
    final current = state.value ?? CloudSyncSettings.defaults();
    final next = current.copyWith(provider: provider);
    await _persist(next);
    state = AsyncData(next);
  }

  /// Updates the remote file configuration and persists the change.
  ///
  /// Sets the remote file ID and name for cloud synchronization.
  /// This is typically used after successful cloud file selection
  /// or upload operations.
  ///
  /// Parameters:
  /// - [id]: Unique identifier for the remote file
  /// - [name]: Name of the remote file in cloud storage
  Future<void> setRemoteFile({
    required String? id,
    required String? name,
  }) async {
    final current = state.value ?? CloudSyncSettings.defaults();
    final next = current.copyWith(remoteFileId: id, remoteFileName: name);
    await _persist(next);
    state = AsyncData(next);
  }

  /// Persists settings to SharedPreferences.
  ///
  /// Serializes the settings to JSON and stores them persistently.
  /// This private method handles the actual storage operation.
  ///
  /// Parameters:
  /// - [settings]: The settings to persist
  Future<void> _persist(CloudSyncSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(settings.toJson()));
  }

  /// Updates the OneDrive client ID and persists the change.
  ///
  /// Sets the client ID for OneDrive authentication. If the provided
  /// client ID is null or empty, it will be stored as null.
  ///
  /// Parameters:
  /// - [clientId]: The OneDrive client ID to use for authentication
  Future<void> setOneDriveClientId(String? clientId) async {
    final current = state.value ?? CloudSyncSettings.defaults();
    final next = current.copyWith(
      oneDriveClientId: (clientId == null || clientId.trim().isEmpty)
          ? null
          : clientId.trim(),
    );
    await _persist(next);
    state = AsyncData(next);
  }

  /// Sets the synchronization baseline values and persists the change.
  ///
  /// Updates the last remote version, last local hash, and last sync timestamp
  /// for tracking synchronization state. These values are used to determine
  /// whether a file has changed since the last sync.
  ///
  /// Parameters:
  /// - [lastRemoteVersion]: The version hash from the remote cloud storage
  /// - [lastLocalHash]: The hash of the local file content
  /// - [lastSyncAt]: The timestamp of the last successful sync
  Future<void> setSyncBaseline({
    required String? lastRemoteVersion,
    required String? lastLocalHash,
    required DateTime? lastSyncAt,
  }) async {
    final current = state.value ?? CloudSyncSettings.defaults();
    final next = current.copyWith(
      lastRemoteVersion: lastRemoteVersion,
      lastLocalHash: lastLocalHash,
      lastSyncTimestamp: lastSyncAt?.millisecondsSinceEpoch,
    );
    await _persist(next);
    state = AsyncData(next);
  }
}

/// Riverpod provider for cloud sync settings management.
///
/// This provider creates and manages an instance of [CloudSyncSettingsNotifier]
/// for accessing and modifying cloud synchronization settings throughout
/// the application. It provides async state management with proper
/// loading states and error handling for cloud configuration.
///
/// Usage:
/// ```dart
/// final settings = ref.watch(cloudSyncSettingsProvider);
/// final notifier = ref.read(cloudSyncSettingsProvider.notifier);
/// await notifier.setProvider(CloudProviderType.googleDrive);
/// await notifier.setRemoteFile(id: 'file123', name: 'budget.kmy');
/// ```
///
/// Returns an [AsyncNotifierProvider] that manages [CloudSyncSettings] state.
final cloudSyncSettingsProvider =
    AsyncNotifierProvider<CloudSyncSettingsNotifier, CloudSyncSettings>(
      CloudSyncSettingsNotifier.new,
    );
