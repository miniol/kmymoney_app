// Copyright (c) 2026 by Zafado.pl
//
// This file is part of kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT
import 'dart:convert';

import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../presentation/providers/cloud_sync_settings_provider.dart';
import 'cloud_file_backend.dart';

/// OneDrive implementation of cloud file backend.
///
/// This class provides concrete implementation of [CloudFileBackend]
/// for OneDrive storage. It handles authentication using Azure AD,
/// file listing with KMyMoney filtering, and proper error handling.
///
/// Features:
/// - Azure AD authentication
/// - KMyMoney file filtering (.kmy extension)
/// - File metadata retrieval (ID, name, modified time)
/// - Pagination support for large file collections
/// - Proper error handling and state management
///
/// Dependencies:
/// - Azure AD for authentication
/// - OneDrive API for file operations
/// - Flutter Secure Storage for token management
class OneDriveBackend implements CloudFileBackend {
  static const _discoveryUrl =
      'https://login.microsoftonline.com/common/v2.0/.well-known/openid-configuration';

  static const _redirectUrl = 'com.zafado.kmymoney_app://oauthredirect';

  // TODO: Put your Azure AD app (Entra ID) Client ID here.
  // You must create an App Registration in Azure portal first.
  final String clientId;

  final FlutterAppAuth _appAuth;
  final FlutterSecureStorage _secureStorage;

  OneDriveBackend({
    required this.clientId,
    FlutterAppAuth? appAuth,
    FlutterSecureStorage? secureStorage,
  }) : _appAuth = appAuth ?? const FlutterAppAuth(),
       _secureStorage = secureStorage ?? const FlutterSecureStorage();

  @override
  CloudProviderType get type => CloudProviderType.oneDrive;

  static const _kAccessTokenKey = 'onedrive_access_token';
  static const _kRefreshTokenKey = 'onedrive_refresh_token';
  static const _kAccessTokenExpiryKey = 'onedrive_access_token_expiry';

  ///
  /// Checks if the user is currently signed in to OneDrive.
  ///
  /// Throws:
  /// - [StateError] if sign-in fails or required tokens are missing
  ///
  /// Returns:
  /// - [Future<bool>] true if the user is signed in, false otherwise
  @override
  Future<bool> isSignedIn() async {
    final refresh = await _secureStorage.read(key: _kRefreshTokenKey);
    return refresh != null && refresh.trim().isNotEmpty;
  }

  ///
  /// Initiates the OAuth 2.0 authorization flow with OneDrive.
  ///
  /// Throws:
  /// - [StateError] if sign-in fails or required tokens are missing
  ///
  /// Returns:
  /// - [Future<void>] when sign-in is complete
  @override
  Future<void> signIn() async {
    late final AuthorizationTokenResponse resp;
    try {
      resp = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          _redirectUrl,
          discoveryUrl: _discoveryUrl,
          scopes: const [
            'openid',
            'profile',
            'offline_access',
            'https://graph.microsoft.com/Files.Read',
          ],
          promptValues: const ['select_account'],
        ),
      );
    } on Exception catch (e) {
      throw StateError('OneDrive: sign-in failed: $e');
    }

    if (resp.accessToken?.isEmpty ?? true) {
      throw StateError('OneDrive: missing access token.');
    }

    if (resp.refreshToken?.isEmpty ?? true) {
      throw StateError(
        'OneDrive: missing refresh token (need offline_access).',
      );
    }

    await _secureStorage.write(key: _kAccessTokenKey, value: resp.accessToken);
    await _secureStorage.write(
      key: _kRefreshTokenKey,
      value: resp.refreshToken,
    );

    final expiry = resp.accessTokenExpirationDateTime;
    if (expiry != null) {
      await _secureStorage.write(
        key: _kAccessTokenExpiryKey,
        value: expiry.toIso8601String(),
      );
    }
  }

  ///
  /// Signs out the user by deleting all stored tokens.
  ///
  /// Throws:
  /// - [StateError] if sign-out fails
  ///
  /// Returns:
  /// - [Future<void>] when sign-out is complete
  @override
  Future<void> signOut() async {
    await _secureStorage.delete(key: _kAccessTokenKey);
    await _secureStorage.delete(key: _kRefreshTokenKey);
    await _secureStorage.delete(key: _kAccessTokenExpiryKey);
  }

  ///
  /// Gets a valid access token for OneDrive API calls.
  ///
  /// Throws:
  /// - [StateError] if not authenticated or token refresh fails
  ///
  /// Returns:
  /// - [String] containing the access token
  Future<String> _getValidAccessToken() async {
    final refresh = await _secureStorage.read(key: _kRefreshTokenKey);
    if (refresh == null || refresh.trim().isEmpty) {
      throw StateError('OneDrive: not signed in.');
    }

    final access = await _secureStorage.read(key: _kAccessTokenKey);
    final expiryRaw = await _secureStorage.read(key: _kAccessTokenExpiryKey);

    final expiry = expiryRaw == null ? null : DateTime.tryParse(expiryRaw);
    final isExpired = expiry == null
        ? true
        : DateTime.now().isAfter(expiry.subtract(const Duration(minutes: 1)));

    if (access != null && access.isNotEmpty && !isExpired) {
      return access;
    }

    final refreshed = await _appAuth.token(
      TokenRequest(
        clientId,
        _redirectUrl,
        discoveryUrl: _discoveryUrl,
        refreshToken: refresh,
        scopes: const [
          'openid',
          'profile',
          'offline_access',
          'https://graph.microsoft.com/Files.Read',
        ],
      ),
    );

    if (refreshed.accessToken?.isEmpty ?? true) {
      throw StateError('OneDrive: refresh token exchange failed.');
    }

    await _secureStorage.write(
      key: _kAccessTokenKey,
      value: refreshed.accessToken,
    );

    final newExpiry = refreshed.accessTokenExpirationDateTime;
    if (newExpiry != null) {
      await _secureStorage.write(
        key: _kAccessTokenExpiryKey,
        value: newExpiry.toIso8601String(),
      );
    }

    return refreshed.accessToken!;
  }

  @override
  Future<List<RemoteFileInfo>> listKmyFiles({int pageSize = 20}) async {
    final token = await _getValidAccessToken();

    // Search in root for ".kmy". This is simple and good enough for Milestone 2.
    // Later you can add browsing folders or using DriveItem picker UI.
    final uri = Uri.parse(
      'https://graph.microsoft.com/v1.0/me/drive/root/search(q=\'.kmy\')'
      '?\$select=id,name'
      '&\$top=$pageSize',
    );

    final resp = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw StateError(
        'OneDrive: list files failed (${resp.statusCode}): ${resp.body}',
      );
    }

    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    final values = (decoded['value'] as List?) ?? const [];

    return values
        .whereType<Map<String, dynamic>>()
        .map((m) {
          final id = (m['id'] as String?) ?? '';
          final name = (m['name'] as String?) ?? '';
          return RemoteFileInfo(id: id, name: name);
        })
        .where((f) => f.id.trim().isNotEmpty)
        .toList();
  }

  ///
  /// Gets metadata for a file from OneDrive by its remote file ID.
  ///
  /// Throws:
  /// - [StateError] if not authenticated or metadata retrieval fails
  /// - [ApiException] for OneDrive API errors
  ///
  /// Returns:
  /// - [RemoteFileMetadata] containing file metadata
  ///
  /// Parameters:
  /// - [remoteFielId] The ID of the file to get metadata for
  @override
  Future<RemoteFileMetadata> getMetadata(String remoteFileId) async {
    final token = await _getValidAccessToken();

    final uri = Uri.parse(
      'https://graph.microsoft.com/v1.0/me/drive/items/$remoteFileId'
      '?\$select=id,name,size,lastModifiedDateTime,cTag,eTag',
    );

    final resp = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw StateError(
        'OneDrive: metadata failed (${resp.statusCode}): ${resp.body}',
      );
    }

    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;

    final id = (decoded['id'] as String?) ?? remoteFileId;
    final name = (decoded['name'] as String?) ?? '';
    final size = decoded['size'] as int?;
    final modifiedRaw = decoded['lastModifiedDateTime'] as String?;
    if (modifiedRaw == null) {
      throw StateError('OneDrive: file has no lastModifiedDateTime.');
    }

    final modifiedAt = DateTime.parse(modifiedRaw);

    final cTag = decoded['cTag'] as String?;
    final eTag = decoded['eTag'] as String?;
    final versionTag = (cTag?.isNotEmpty ?? false) ? cTag! : (eTag ?? '');

    return RemoteFileMetadata(
      id: id,
      name: name,
      versionTag: versionTag,
      modifiedAt: modifiedAt,
      size: size,
    );
  }

  ///
  /// Downloads a file from OneDrive by its remote file ID.
  ///
  /// Throws:
  /// - [StateError] if not authenticated or download fails
  /// - [ApiException] for OneDrive API errors
  ///
  /// Returns:
  /// - [List<int>] containing the file data
  ///
  /// Parameters:
  /// - [remoteFileId] The ID of the file to download
  @override
  Future<List<int>> download(String remoteFileId) async {
    final token = await _getValidAccessToken();

    final uri = Uri.parse(
      'https://graph.microsoft.com/v1.0/me/drive/items/$remoteFileId/content',
    );

    final resp = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw StateError(
        'OneDrive: download failed (${resp.statusCode}): ${resp.body}',
      );
    }

    return resp.bodyBytes;
  }

  ///
  /// Uploads a file to OneDrive.
  ///
  /// Throws:
  /// - [StateError] if not authenticated or upload fails
  /// - [ApiException] for OneDrive API errors
  ///
  /// Returns:
  /// - [RemoteFileMetadata] containing the file metadata
  ///
  /// Parameters:
  /// - [fileName] The name of the file to upload
  /// - [bytes] The file data to upload
  @override
  Future<RemoteFileMetadata> upload(String fileName, List<int> bytes) async {
    final token = await _getValidAccessToken();

    // Check if file already exists in root
    final checkUri = Uri.parse(
      'https://graph.microsoft.com/v1.0/me/drive/root/children/\$search(q=\'$fileName\')?\$select=id,name',
    );

    final checkResp = await http.get(
      checkUri,
      headers: {'Authorization': 'Bearer $token'},
    );

    String? existingId;
    if (checkResp.statusCode >= 200 && checkResp.statusCode < 300) {
      final decoded = jsonDecode(checkResp.body) as Map<String, dynamic>;
      final values = (decoded['value'] as List?) ?? const [];
      if (values.isNotEmpty) {
        existingId = (values.first as Map<String, dynamic>)['id'] as String?;
      }
    }

    final uri = existingId != null
        ? Uri.parse(
            'https://graph.microsoft.com/v1.0/me/drive/items/$existingId/content',
          )
        : Uri.parse(
            'https://graph.microsoft.com/v1.0/me/drive/root:/$fileName:/content',
          );

    final resp = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/octet-stream',
      },
      body: bytes,
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw StateError(
        'OneDrive: upload failed (${resp.statusCode}): ${resp.body}',
      );
    }

    // Get metadata after upload
    final metadataUri = existingId != null
        ? Uri.parse(
            'https://graph.microsoft.com/v1.0/me/drive/items/$existingId?\$select=id,name,size,lastModifiedDateTime,cTag,eTag',
          )
        : Uri.parse(
            'https://graph.microsoft.com/v1.0/me/drive/root:/$fileName?\$select=id,name,size,lastModifiedDateTime,cTag,eTag',
          );

    final metaResp = await http.get(
      metadataUri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (metaResp.statusCode < 200 || metaResp.statusCode >= 300) {
      throw StateError(
        'OneDrive: metadata after upload failed (${metaResp.statusCode}): ${metaResp.body}',
      );
    }

    final decoded = jsonDecode(metaResp.body) as Map<String, dynamic>;
    final id = (decoded['id'] as String?) ?? '';
    final name = (decoded['name'] as String?) ?? fileName;
    final size = decoded['size'] as int?;
    final modifiedRaw = decoded['lastModifiedDateTime'] as String?;
    final modifiedAt = modifiedRaw != null
        ? DateTime.parse(modifiedRaw)
        : DateTime.now();

    final cTag = decoded['cTag'] as String?;
    final eTag = decoded['eTag'] as String?;
    final versionTag = (cTag?.isNotEmpty ?? false) ? cTag! : (eTag ?? '');

    return RemoteFileMetadata(
      id: id,
      name: name,
      versionTag: versionTag,
      modifiedAt: modifiedAt,
      size: size,
    );
  }
}
