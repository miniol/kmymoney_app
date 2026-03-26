// Copyright (c) 2026
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// KMyMoney Repository Interface
//
// Defines the contract for KMyMoney data operations.
// Enables dependency injection and testing.

/// Repository interface for KMyMoney data operations.
///
/// This abstract class defines the contract for loading and managing
/// KMyMoney data, enabling dependency injection and facilitating
/// unit testing through mock implementations.
///
/// Implementations should handle file parsing, data validation,
/// and error management according to the specific requirements.
abstract class KmyRepository {
  /// Loads KMyMoney data from the specified file path.
  ///
  /// This method should handle file reading, parsing, and data
  /// validation. It may throw exceptions for file not found,
  /// parsing errors, or invalid data formats.
  ///
  /// Parameters:
  /// - [path]: File system path to the KMyMoney file
  ///
  /// Throws [FileSystemException] if file cannot be read.
  /// Throws [FormatException] if file content is invalid.
  Future<void> loadFromPath(String path);
}
