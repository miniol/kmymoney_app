// Copyright (c) 2026 by Zafado.pl
//
// This file is part of kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// Cloud Sync Domain Layer
//
// Domain models and interfaces for cloud synchronization.
// Defines cloud backend abstraction and remote file information.

import '../../presentation/providers/cloud_sync_settings_provider.dart';

/// Immutable model representing information about a remote file.
///
/// This class encapsulates the essential information needed to
/// identify and reference a file stored in cloud storage. It provides
/// a clean abstraction for remote file operations without exposing
/// cloud-specific implementation details.
///
/// Properties:
/// - [id]: Unique identifier for the remote file (cloud-specific)
/// - [name]: Human-readable name of the remote file
class RemoteFileInfo {
  /// Unique identifier for the remote file.
  ///
  /// This ID is specific to the cloud storage provider and
  /// is used for file operations like download, upload, and deletion.
  final String id;

  /// Human-readable name of the remote file.
  ///
  /// The filename as displayed in the cloud storage interface,
  /// typically including the file extension.
  final String name;

  /// Creates remote file information with specified ID and name.
  ///
  /// Parameters:
  /// - [id]: Unique identifier for the remote file
  /// - [name]: Human-readable file name
  const RemoteFileInfo({required this.id, required this.name});
}

/// Metadata for a remote file.
///
/// This class encapsulates the metadata needed to
/// identify and reference a file stored in cloud storage.
///
/// Properties:
/// - [id]: Unique identifier for the remote file (cloud-specific)
/// - [name]: Human-readable name of the remote file
/// - [versionTag]: Version tag for the remote file (cloud-specific)
/// - [modifiedAt]: Last modified date of the remote file
/// - [size]: Size of the remote file in bytes
class RemoteFileMetadata {
  final String id;
  final String name;
  final String versionTag;
  final DateTime modifiedAt;
  final int? size;

  RemoteFileMetadata({
    required this.id,
    required this.name,
    required this.versionTag,
    required this.modifiedAt,
    required this.size,
  });
}

/// Abstract interface for cloud storage backends.
///
/// This abstract class defines the contract that all cloud storage
/// implementations must follow. It provides a unified interface
/// for different cloud providers while allowing provider-specific
/// implementations to handle the details of authentication and file operations.
///
/// Implementations should handle:
/// - Authentication flow (sign in/out)
/// - File listing and filtering
/// - Provider-specific error handling
/// - Rate limiting and retry logic
///
/// Supported operations:
/// - Authentication status checking
/// - User authentication management
/// - KMyMoney file listing with pagination
abstract class CloudFileBackend {
  /// Gets the type of cloud provider this backend implements.
  ///
  /// Returns the specific cloud provider type (Google Drive, OneDrive, etc.)
  /// that this backend instance is configured to work with.
  ///
  /// Returns the [CloudProviderType] for this backend.
  CloudProviderType get type;

  /// Checks if the user is currently authenticated with the cloud provider.
  ///
  /// Verifies the authentication status without triggering any user
  /// interaction. This should be a lightweight check that can be called
  /// frequently to update UI state.
  ///
  /// Returns:
  /// - true if the user is authenticated and has valid credentials
  /// - false if not authenticated or credentials are expired
  ///
  /// May throw provider-specific exceptions for network or authentication errors.
  Future<bool> isSignedIn();

  /// Initiates the authentication flow with the cloud provider.
  ///
  /// Starts the sign-in process which may involve opening a web browser,
  /// showing a dialog, or other provider-specific authentication methods.
  /// This method should handle the complete authentication flow including
  /// token exchange and credential storage.
  ///
  /// May throw:
  /// - AuthenticationException for failed authentication
  /// - NetworkException for connectivity issues
  /// - Provider-specific exceptions
  Future<void> signIn();

  /// Signs out the user from the cloud provider.
  ///
  /// Clears stored credentials and invalidates any active sessions.
  /// After calling this method, the user will need to authenticate again
  /// to access cloud files.
  ///
  /// May throw provider-specific exceptions for network or storage errors.
  Future<void> signOut();

  /// Lists KMyMoney files available in the cloud storage.
  ///
  /// Retrieves a list of files with .kmy extension from the user's
  /// cloud storage. Supports pagination to handle large numbers of files
  /// and implements provider-specific filtering and sorting.
  ///
  /// Parameters:
  /// - [pageSize]: Maximum number of files to return (default: 20)
  ///
  /// Returns a list of [RemoteFileInfo] objects containing file metadata.
  ///
  /// May throw:
  /// - AuthenticationException if not signed in
  /// - NetworkException for connectivity issues
  /// - Provider-specific exceptions for API errors
  Future<List<RemoteFileInfo>> listKmyFiles({int pageSize = 20});

  /// Retrieves metadata for a specific file.
  ///
  /// Gets detailed information about a file including size, modification time,
  /// and other provider-specific attributes.
  ///
  /// Parameters:
  /// - [remoteFielId]: The unique identifier of the file
  ///
  /// Returns a [RemoteFileMetadata] object containing file metadata.
  ///
  /// May throw:
  /// - AuthenticationException if not signed in
  /// - NetworkException for connectivity issues
  /// - Provider-specific exceptions for API errors
  Future<RemoteFileMetadata> getMetadata(String remoteFielId);

  /// Downloads a file from the cloud storage.
  ///
  /// Retrieves the file content as a byte array from the specified remote file ID.
  ///
  /// Parameters:
  /// - [remoteFileId]: The unique identifier of the file to download
  ///
  /// Returns the file content as a list of bytes.
  ///
  /// May throw:
  /// - AuthenticationException if not signed in
  /// - NetworkException for connectivity issues
  /// - Provider-specific exceptions for API errors
  Future<List<int>> download(String remoteFileId);
}
