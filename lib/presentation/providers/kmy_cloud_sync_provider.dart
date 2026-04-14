// Copyright (c) 2026 by Zafado.pl
//
// This file is part of kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// KMyMoney Cloud Sync Provider
//
// Riverpod provider for cloud synchronization operations.
// Handles file version checking, downloading, and atomic updates.

import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../domain/cloud/cloud_file_backend.dart';
import '../providers/cloud_backend_provider.dart';
import '../providers/cloud_sync_settings_provider.dart';
import '../providers/kmy_local_path_provider.dart';

/// Enumeration of cloud sync check results.
///
/// Defines the possible outcomes when checking for
/// updates to the cloud-stored KMyMoney file.
enum CloudSyncCheckResult { notConfigured, upToDate, updateAvailable }

/// Result model for cloud sync download operations.
///
/// Encapsulates the outcome of a sync operation, indicating
/// whether a download occurred and the local file path.
class CloudSyncDownloadResult {
  /// Whether a new file was downloaded from the cloud.
  final bool downloaded;

  /// Local path where the file was saved or currently exists.
  final String? localPath;

  /// Creates sync download result with specified status and path.
  ///
  /// Parameters:
  /// - [downloaded]: Whether a new download occurred
  /// - [localPath]: Local file path (nullable)
  const CloudSyncDownloadResult({
    required this.downloaded,
    required this.localPath,
  });
}

/// Riverpod AsyncNotifier for KMyMoney cloud synchronization.
///
/// This notifier handles cloud synchronization operations including
/// version checking, downloading updates, and atomic file writes.
/// It integrates with cloud backends and local file management
/// to provide seamless synchronization between cloud and local files.
///
/// Features:
/// - Version comparison using cloud metadata
/// - Atomic file downloads to prevent corruption
/// - Hash verification for file integrity
/// - Configuration validation and error handling
/// - Sync baseline tracking for future comparisons
class KmyCloudSyncNotifier extends AsyncNotifier<void> {
  /// Builds the notifier with no initial state.
  ///
  /// This notifier doesn't maintain persistent state
  /// but provides async operations for cloud sync.
  @override
  Future<void> build() async {}

  /// Checks if cloud updates are available for the configured file.
  ///
  /// Compares the remote file version with the last synced version
  /// to determine if an update is available. Validates that cloud
  /// sync is properly configured before checking.
  ///
  /// Returns:
  /// - [CloudSyncCheckResult.notConfigured]: Cloud sync not set up
  /// - [CloudSyncCheckResult.upToDate]: Local file is current
  /// - [CloudSyncCheckResult.updateAvailable]: New version available
  ///
  /// May throw exceptions for network or authentication errors.
  Future<CloudSyncCheckResult> checkForUpdates() async {
    final cloudSettings = await ref.read(cloudSyncSettingsProvider.future);
    final backend = ref.read(activeCloudBackendProvider);

    final remoteFileId = cloudSettings.remoteFileId;
    if (backend == null ||
        remoteFileId == null ||
        remoteFileId.trim().isEmpty) {
      return CloudSyncCheckResult.notConfigured;
    }

    final meta = await backend.getMetadata(remoteFileId);

    final lastRemoteVersion = cloudSettings.lastRemoteVersion;
    if (lastRemoteVersion == null || lastRemoteVersion.isEmpty) {
      return CloudSyncCheckResult.updateAvailable;
    }

    return meta.versionTag == lastRemoteVersion
        ? CloudSyncCheckResult.upToDate
        : CloudSyncCheckResult.updateAvailable;
  }

  /// Synchronizes the local file with cloud version if newer.
  ///
  /// Downloads the cloud file if it's newer than the local version,
  /// writes it atomically to prevent corruption, and updates the
  /// sync baseline with new version information and file hash.
  ///
  /// Returns [CloudSyncDownloadResult] indicating whether a download
  /// occurred and the local file path.
  ///
  /// State management:
  /// - Sets AsyncLoading during operation
  /// - Sets AsyncData on completion
  /// - Sets AsyncError on failure
  ///
  /// May rethrow exceptions for network, authentication, or file errors.
  Future<CloudSyncDownloadResult> syncNowDownloadIfNewer() async {
    state = const AsyncLoading();

    try {
      final cloudSettings = await ref.read(cloudSyncSettingsProvider.future);
      final cloudSettingsNotifier = ref.read(
        cloudSyncSettingsProvider.notifier,
      );

      final backend = ref.read(activeCloudBackendProvider);
      final remoteFileId = cloudSettings.remoteFileId;

      final localPath = await ref.read(kmyLocalPathProvider.future);

      if (backend == null ||
          remoteFileId == null ||
          remoteFileId.trim().isEmpty ||
          localPath == null ||
          localPath.trim().isEmpty) {
        state = const AsyncData(null);
        return const CloudSyncDownloadResult(
          downloaded: false,
          localPath: null,
        );
      }

      final meta = await backend.getMetadata(remoteFileId);

      final lastRemoteVersion = cloudSettings.lastRemoteVersion;
      final isNewer = (lastRemoteVersion == null || lastRemoteVersion.isEmpty)
          ? true
          : meta.versionTag != lastRemoteVersion;

      if (!isNewer) {
        state = const AsyncData(null);
        return CloudSyncDownloadResult(downloaded: false, localPath: localPath);
      }

      final bytes = await backend.download(remoteFileId);

      await _atomicWriteBytes(targetPath: localPath, bytes: bytes);

      final localHash = sha256.convert(bytes).toString();

      await cloudSettingsNotifier.setSyncBaseline(
        lastRemoteVersion: meta.versionTag,
        lastLocalHash: localHash,
        lastSyncAt: DateTime.now(),
      );

      state = const AsyncData(null);
      return CloudSyncDownloadResult(downloaded: true, localPath: localPath);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Writes bytes to file atomically to prevent corruption.
  ///
  /// Creates a temporary file, writes the bytes, flushes to disk,
  /// then atomically replaces the target file. This ensures that
  /// the target file is never left in a partially written state.
  ///
  /// Parameters:
  /// - [targetPath]: Destination file path
  /// - [bytes]: File content as byte list
  ///
  /// Creates parent directories if they don't exist.
  Future<void> _atomicWriteBytes({
    required String targetPath,
    required List<int> bytes,
  }) async {
    final targetFile = File(targetPath);
    final dir = targetFile.parent;

    // Create parent directory if it doesn't exist
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // Create temporary file for atomic write
    final tmpPath = '$targetPath.download';
    final tmpFile = File(tmpPath);

    // Write bytes to temporary file with flush
    await tmpFile.writeAsBytes(bytes, flush: true);

    // Remove existing target file if it exists
    if (await targetFile.exists()) {
      await targetFile.delete();
    }

    // Atomically rename temporary file to target path
    await tmpFile.rename(targetPath);
  }
}

/// Riverpod provider for KMyMoney cloud synchronization operations.
///
/// This provider creates and manages an instance of [KmyCloudSyncNotifier]
/// for performing cloud synchronization tasks throughout the application.
/// It provides access to version checking, downloading, and sync operations
/// with proper async state management.
///
/// Usage:
/// ```dart
/// final notifier = ref.read(kmyCloudSyncProvider.notifier);
/// final result = await notifier.checkForUpdates();
/// if (result == CloudSyncCheckResult.updateAvailable) {
///   final downloadResult = await notifier.syncNowDownloadIfNewer();
/// }
/// ```
///
/// Returns an [AsyncNotifierProvider] for cloud sync operations.
final kmyCloudSyncProvider = AsyncNotifierProvider<KmyCloudSyncNotifier, void>(
  KmyCloudSyncNotifier.new,
);
