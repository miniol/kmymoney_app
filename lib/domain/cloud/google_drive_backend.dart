// Copyright (c) 2026 by Zafado.pl
//
// This file is part of kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// Google Drive Backend Implementation
//
// Concrete implementation of cloud backend for Google Drive.
// Handles authentication and file operations for Google Drive.

import 'dart:typed_data';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import '../../presentation/providers/cloud_sync_settings_provider.dart';
import 'cloud_file_backend.dart';

/// Google Drive implementation of cloud file backend.
///
/// This class provides concrete implementation of [CloudFileBackend]
/// for Google Drive storage. It handles authentication using Google Sign-In,
/// file listing with KMyMoney filtering, and proper error handling.
///
/// Features:
/// - Google Sign-In authentication
/// - KMyMoney file filtering (.kmy extension)
/// - File metadata retrieval (ID, name, modified time)
/// - Pagination support for large file collections
/// - Proper error handling and state management
///
/// Dependencies:
/// - Google Sign-In for authentication
/// - Google Drive API v3 for file operations
/// - Extension for authenticated API access
class GoogleDriveBackend implements CloudFileBackend {
  /// Google Sign-In instance for authentication.
  ///
  /// Handles user authentication flow and provides access
  /// tokens for Google Drive API operations.
  final GoogleSignIn _googleSignIn;

  /// Creates Google Drive backend with optional Google Sign-In instance.
  ///
  /// Parameters:
  /// - [googleSignIn]: Optional GoogleSignIn instance, defaults to new instance
  ///   with Drive readonly scope if not provided
  ///
  /// Configures the backend for Google Drive operations with
  /// proper authentication scope for file reading.
  GoogleDriveBackend({GoogleSignIn? googleSignIn})
    : _googleSignIn =
          googleSignIn ??
          GoogleSignIn(scopes: const [drive.DriveApi.driveScope]);

  /// Returns Google Drive as the cloud provider type.
  @override
  CloudProviderType get type => CloudProviderType.googleDrive;

  /// Gets authenticated Google Drive API client.
  ///
  /// Retrieves authenticated client for API operations.
  /// Throws [StateError] if user is not signed in.
  ///
  /// Returns authenticated [drive.DriveApi] instance.
  Future<drive.DriveApi> _getDriveApi() async {
    final client = await _googleSignIn.authenticatedClient();
    if (client == null) {
      throw StateError('Google Drive: not signed in.');
    }
    return drive.DriveApi(client);
  }

  /// Checks if user is authenticated with Google Drive.
  ///
  /// Delegates to Google Sign-In authentication status.
  ///
  /// Returns true if user is signed in and has valid credentials.
  @override
  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  /// Initiates Google Sign-In authentication flow.
  ///
  /// Starts the Google Sign-In process which may show
  /// account selection dialog and request user consent.
  /// Throws [StateError] if user cancels the sign-in process.
  ///
  /// If user is already signed in, attempts silent sign-in first.
  /// This allows for automatic re-authentication without user interaction
  /// when credentials are still valid.
  ///
  /// Completes when user successfully authenticates.
  @override
  Future<void> signIn() async {
    final alreadySignedIn = await _googleSignIn.isSignedIn();
    if (alreadySignedIn) {
      final account = await _googleSignIn.signInSilently();
      if (account != null) return;
    }

    final account = await _googleSignIn.signIn();
    if (account == null) {
      throw StateError('Google Drive: sign-in aborted.');
    }
  }

  /// Signs out user from Google Drive.
  ///
  /// Clears stored credentials and invalidates any active
  /// authentication sessions.
  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  /// Lists KMyMoney files from Google Drive.
  ///
  /// Retrieves files with .kmy extension from the user's Drive,
  /// sorted by modification time (newest first). Supports pagination
  /// and filters out trashed files.
  ///
  /// Parameters:
  /// - [pageSize]: Maximum number of files to return (default: 20)
  ///
  /// Returns list of [RemoteFileInfo] objects containing file metadata.
  ///
  /// Throws:
  /// - [StateError] if not authenticated
  /// - [ApiException] for Google Drive API errors
  @override
  Future<List<RemoteFileInfo>> listKmyFiles({int pageSize = 20}) async {
    final api = await _getDriveApi();

    // Query for non-trashed KMyMoney files with specified page size
    final resp = await api.files.list(
      q: "trashed = false and (name contains '.kmy')",
      pageSize: pageSize,
      spaces: 'drive',
      $fields: 'files(id,name)',
      orderBy: 'modifiedTime desc',
      corpora: 'user',
    );

    // Extract files from response, defaulting to empty list
    final files = resp.files ?? const <drive.File>[];

    // Filter out files with empty IDs and convert to RemoteFileInfo
    return files
        .where((f) => (f.id ?? '').trim().isNotEmpty)
        .map((f) => RemoteFileInfo(id: f.id!, name: (f.name ?? '').trim()))
        .toList();
  }

  ///
  /// Gets metadata for a file from Google Drive by its remote file ID.
  ///
  /// Throws:
  /// - [StateError] if not authenticated or metadata retrieval fails
  /// - [ApiException] for Google Drive API errors
  ///
  /// Returns:
  /// - [RemoteFileMetadata] containing file metadata
  ///
  /// Parameters:
  /// - [remoteFielId] The ID of the file to get metadata for
  @override
  Future<RemoteFileMetadata> getMetadata(String remoteFileId) async {
    final api = await _getDriveApi();

    final result = await api.files.get(
      remoteFileId,
      $fields: 'id,name,modifiedTime,md5Checksum,version,size',
    );

    if (result is! drive.File) {
      throw StateError('Google Drive: metadata request did not return a File.');
    }
    final f = result;

    final id = f.id ?? remoteFileId;
    final name = f.name ?? '';
    final modifiedAt = f.modifiedTime;
    if (modifiedAt == null) {
      throw StateError('Google Drive: file has no modifiedTime.');
    }

    final versionTag = (f.md5Checksum?.trim().isNotEmpty ?? false)
        ? f.md5Checksum!
        : (f.version?.toString() ?? '');

    final size = f.size == null ? null : int.tryParse(f.size!);

    return RemoteFileMetadata(
      id: id,
      name: name,
      versionTag: versionTag,
      modifiedAt: modifiedAt,
      size: size,
    );
  }

  ///
  /// Downloads a file from Google Drive by its remote file ID.
  ///
  /// Throws:
  /// - [StateError] if not authenticated or download fails
  /// - [ApiException] for Google Drive API errors
  ///
  /// Returns:
  /// - [List<int>] containing the file data
  ///
  /// Parameters:
  /// - [remoteFileId] The ID of the file to download
  @override
  Future<List<int>> download(String remoteFileId) async {
    final api = await _getDriveApi();

    final media = await api.files.get(
      remoteFileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    );

    if (media is! drive.Media) {
      throw StateError('Google Drive: download did not return media.');
    }

    final chunks = <int>[];
    await for (final chunk in media.stream) {
      chunks.addAll(chunk);
    }
    return Uint8List.fromList(chunks);
  }

  ///
  /// Uploads a file to Google Drive.
  ///
  /// Throws:
  /// - [StateError] if not authenticated or upload fails
  /// - [ApiException] for Google Drive API errors
  ///
  /// Returns:
  /// - [RemoteFileMetadata] containing the file metadata
  ///
  /// Parameters:
  /// - [fileName] The name of the file to upload
  /// - [bytes] The file data to upload
  @override
  Future<RemoteFileMetadata> upload(String fileName, List<int> bytes) async {
    final api = await _getDriveApi();

    // Check if file already exists
    final existing = await api.files.list(
      q: "trashed = false and name = '$fileName'",
      spaces: 'drive',
      $fields: 'files(id)',
      pageSize: 1,
    );

    drive.File result;
    if (existing.files != null && existing.files!.isNotEmpty) {
      // Update existing file
      final existingId = existing.files!.first.id;
      result = await api.files.update(
        drive.File(),
        existingId!,
        uploadMedia: drive.Media(Stream.value(bytes), bytes.length),
      );
    } else {
      // Create new file
      final fileMetadata = drive.File(name: fileName);
      result = await api.files.create(
        fileMetadata,
        uploadMedia: drive.Media(Stream.value(bytes), bytes.length),
      );
    }

    // if (result is! drive.File) {
    //   throw StateError('Google Drive: upload did not return a File.');
    // }

    final id = result.id ?? '';
    final name = result.name ?? fileName;
    final modifiedAt = result.modifiedTime ?? DateTime.now();
    final versionTag = (result.md5Checksum?.trim().isNotEmpty ?? false)
        ? result.md5Checksum!
        : (result.version?.toString() ?? '');
    final size = result.size == null ? null : int.tryParse(result.size!);

    return RemoteFileMetadata(
      id: id,
      name: name,
      versionTag: versionTag,
      modifiedAt: modifiedAt,
      size: size,
    );
  }
}
