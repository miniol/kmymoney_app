// Copyright (c) 2026 by Zafado.pl
//
// This file is part of kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// Cloud Backend Provider
//
// Riverpod providers for cloud backend instances.
// Manages dependency injection and active backend selection.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/cloud/cloud_file_backend.dart';
import '../../domain/cloud/google_drive_backend.dart';
import '../../domain/cloud/one_drive_backend.dart';
import 'cloud_sync_settings_provider.dart';

/// Riverpod provider for Google Drive backend instance.
///
/// This provider creates and manages a singleton instance of
/// [GoogleDriveBackend] for use throughout the application.
/// Google Drive backend doesn't require additional configuration
/// as it uses default Google Sign-In settings.
///
/// Returns a [Provider] that provides [GoogleDriveBackend] instance.
final googleDriveBackendProvider = Provider<GoogleDriveBackend>((ref) {
  return GoogleDriveBackend();
});

/// Riverpod provider for OneDrive backend instance.
///
/// This provider creates a [OneDriveBackend] instance only when
/// the required client ID is configured in the cloud sync settings.
/// Returns null if the OneDrive client ID is not properly configured,
/// allowing the application to gracefully handle missing OneDrive support.
///
/// Dependencies:
/// - [cloudSyncSettingsProvider] for OneDrive client ID
///
/// Returns a [Provider] that provides nullable [OneDriveBackend] instance.
final oneDriveBackendProvider = Provider<OneDriveBackend?>((ref) {
  final settingsAsync = ref.watch(cloudSyncSettingsProvider);
  final settings = settingsAsync.valueOrNull;
  final clientId = settings?.oneDriveClientId;

  if (clientId == null || clientId.trim().isEmpty) {
    return null;
  }

  return OneDriveBackend(clientId: clientId);
});

/// Riverpod provider for the currently active cloud backend.
///
/// This provider determines which cloud backend should be used based
/// on the user's cloud sync settings. It watches the settings provider
/// and returns the appropriate backend instance (Google Drive or OneDrive)
/// or null if no backend is properly configured.
///
/// Features:
/// - Dynamic backend selection based on user preferences
/// - Graceful handling of missing configurations
/// - Reactive updates when settings change
/// - Provider dependency management
///
/// Dependencies:
/// - [cloudSyncSettingsProvider] for provider type selection
/// - [googleDriveBackendProvider] for Google Drive backend
/// - [oneDriveBackendProvider] for OneDrive backend
///
/// Returns a [Provider] that provides nullable [CloudFileBackend] instance.
final activeCloudBackendProvider = Provider<CloudFileBackend?>((ref) {
  final settingsAsync = ref.watch(cloudSyncSettingsProvider);

  return settingsAsync.maybeWhen(
    data: (settings) {
      switch (settings.provider) {
        case CloudProviderType.googleDrive:
          return ref.watch(googleDriveBackendProvider);
        case CloudProviderType.oneDrive:
          return ref.watch(oneDriveBackendProvider);
      }
    },
    orElse: () => null,
  );
});
