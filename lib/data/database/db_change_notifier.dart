// Copyright (c) 2026 by Zafado.pl
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// Database Change Notifier
//
// Emits events when database changes occur.
// Compensates for sqflite not being reactive.

import 'dart:async';

/// Singleton notifier for database change events.
///
/// Since sqflite is not reactive and doesn't emit table change events,
/// this singleton manually emits change notifications to notify
/// listeners when the database is modified.
///
/// Usage:
/// ```dart
/// DbChangeNotifier.instance.stream.listen((_) {
///   // Refresh UI data
/// });
/// ```
class DbChangeNotifier {
  /// Singleton instance for global access.
  static final DbChangeNotifier instance = DbChangeNotifier._internal();

  /// Stream controller for broadcasting change events.
  final _controller = StreamController<void>.broadcast();

  /// Private constructor for singleton pattern.
  DbChangeNotifier._internal();

  /// Stream of database change events.
  ///
  /// Subscribe to this stream to be notified when
  /// the database changes. The stream emits void
  /// events, indicating that data should be refreshed.
  Stream<void> get stream => _controller.stream;

  /// Notifies all listeners of a database change.
  ///
  /// Call this method whenever data is modified in the database
  /// to trigger UI updates throughout the application.
  void notify() {
    _controller.add(null);
  }
}
