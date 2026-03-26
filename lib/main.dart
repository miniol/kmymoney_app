// Copyright (c) 2026 by Zafado.pl
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// KMyMoney App Main Entry Point
//
// Initializes the Flutter application with database support,
// dependency injection, and app-wide configuration.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/database_initializer.dart';
import 'presentation/providers/app_settings_provider.dart';
import 'presentation/screens/main_tabs_screen.dart';

/// Main entry point for the KMyMoney Flutter application.
///
/// Initializes the Flutter framework, database support, and launches
/// the app with Riverpod state management and Material Design 3.
///
/// The app follows a clean architecture pattern with:
/// - Riverpod for dependency injection and state management
/// - Material Design 3 for theming
/// - SQLite database for local data storage
/// - Localization support for internationalization
void main() async {
  // Ensures Flutter bindings are initialized before async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite database support for desktop platforms
  await DatabaseInitializer.initialize();

  // Launch the app with Riverpod provider scope
  runApp(const ProviderScope(child: MyApp()));
}

/// Root widget of the KMyMoney application.
///
/// Configures the MaterialApp with theme settings, localization,
/// and app-wide providers. Uses ConsumerWidget to access app settings
/// from Riverpod state management.
///
/// Features:
/// - Material Design 3 theming
/// - Dark/light theme switching
/// - Localization support
/// - Debug banner disabled for production
///
/// The app wraps all widgets in a ProviderScope to enable
/// Riverpod dependency injection throughout the widget tree.
class MyApp extends ConsumerWidget {
  /// Creates the root app widget.
  const MyApp({super.key});

  /// Builds the MaterialApp configuration.
  ///
  /// Watches the app settings provider to apply user preferences
  /// for theme mode and locale. Configures Material Design 3,
  /// localization delegates, and sets the home screen.
  ///
  /// Parameters:
  /// - [context]: The build context
  /// - [ref]: The widget reference for accessing providers
  ///
  /// Returns a configured MaterialApp widget.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    return MaterialApp(
      // Disable debug banner for production builds
      debugShowCheckedModeBanner: false,

      // Material Design 3 themes
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: settings.themeMode,

      // Localization configuration
      locale: settings.locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],

      // Main app entry point
      home: const MainTabsScreen(),
    );
  }
}
