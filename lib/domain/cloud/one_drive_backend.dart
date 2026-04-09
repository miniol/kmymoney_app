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

  @override
  Future<bool> isSignedIn() async {
    final refresh = await _secureStorage.read(key: _kRefreshTokenKey);
    return refresh != null && refresh.trim().isNotEmpty;
  }

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

  @override
  Future<void> signOut() async {
    await _secureStorage.delete(key: _kAccessTokenKey);
    await _secureStorage.delete(key: _kRefreshTokenKey);
    await _secureStorage.delete(key: _kAccessTokenExpiryKey);
  }

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

    if (refreshed == null ||
        refreshed.accessToken == null ||
        refreshed.accessToken!.isEmpty) {
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
}
