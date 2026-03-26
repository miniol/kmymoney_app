// Copyright (c) 2026 by Zafado.pl
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// App Settings Provider
//
// Riverpod providers for application settings.
// Manages theme and locale preferences.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Immutable model for application settings.
///
/// This class holds global application preferences including
/// theme mode and locale settings. It's designed to be
/// immutable and provides convenient factory methods and
/// copyWith functionality for state management.
///
/// Properties:
/// - [themeMode]: Current theme mode (light, dark, system)
/// - [locale]: Current locale for internationalization
@immutable
class AppSettings {
  /// Current theme mode for the application.
  final ThemeMode themeMode;

  /// Current locale for internationalization.
  final Locale locale;

  /// Creates application settings with specified theme and locale.
  ///
  /// Parameters:
  /// - [themeMode]: Theme mode to use
  /// - [locale]: Locale for language/region settings
  const AppSettings({required this.themeMode, required this.locale});

  /// Creates default application settings.
  ///
  /// Returns settings with system theme and English locale.
  /// Used as the initial state when no preferences are saved.
  ///
  /// Returns default [AppSettings] instance.
  factory AppSettings.defaults() {
    return const AppSettings(themeMode: ThemeMode.system, locale: Locale('en'));
  }

  /// Creates a copy of this settings with updated values.
  ///
  /// Provides immutable state updates by creating a new
  /// instance with specified fields changed. Unspecified
  /// fields retain their original values.
  ///
  /// Parameters:
  /// - [themeMode]: New theme mode (optional)
  /// - [locale]: New locale (optional)
  ///
  /// Returns new [AppSettings] with updated values.
  AppSettings copyWith({ThemeMode? themeMode, Locale? locale}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}

/// Riverpod notifier for application settings state.
///
/// This notifier manages the global application settings state
/// including theme mode and locale preferences. It provides
/// methods to update individual settings while maintaining
/// immutable state patterns.
///
/// State management:
/// - [AppSettings] holds current configuration
/// - Individual methods for updating each setting
/// - Immutable state updates with copyWith pattern
class AppSettingsNotifier extends StateNotifier<AppSettings> {
  /// Creates notifier with default application settings.
  ///
  /// Initializes with [AppSettings.defaults()] which provides
  /// sensible default values for theme and locale.
  AppSettingsNotifier() : super(AppSettings.defaults());

  /// Updates the application theme mode.
  ///
  /// Changes the theme mode and updates the state.
  /// Supports light, dark, and system theme modes.
  ///
  /// Parameters:
  /// - [mode]: New theme mode to apply
  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  /// Updates the application locale.
  ///
  /// Changes the locale for internationalization and
  /// updates the state accordingly.
  ///
  /// Parameters:
  /// - [locale]: New locale to apply
  void setLocale(Locale locale) {
    state = state.copyWith(locale: locale);
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>(
      (ref) => AppSettingsNotifier(),
    );
