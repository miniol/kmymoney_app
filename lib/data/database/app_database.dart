// Copyright (c) 2026 by Zafado.pl
//
// This file is part of the kmymoney_app Flutter project.
//
// SPDX-License-Identifier: MIT

// Application Database
//
// SQLite database management for the KMyMoney app.
// Handles database initialization and migrations.

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// SQLite database manager for the KMyMoney application.
///
/// This singleton class manages the SQLite database connection,
/// schema creation, and migrations. It provides a centralized
/// point for all database operations throughout the app.
///
/// Database schema includes:
/// - accounts: Financial accounts with metadata
/// - transactions: Transaction headers with dates
/// - splits: Transaction line items with amounts
/// - schedules: Recurring transactions
/// - payees: Transaction recipients/payers
class AppDatabase {
  /// Singleton instance for global database access.
  static final AppDatabase instance = AppDatabase._init();

  /// Internal database connection instance.
  static Database? _database;

  /// Private constructor for singleton pattern.
  AppDatabase._init();

  /// Gets the database instance, initializing if necessary.
  ///
  /// Implements lazy initialization pattern to ensure the database
  /// is created only once and reused throughout the app.
  ///
  /// Returns the active [Database] instance.
  Future<Database> get database async {
    if (_database != null) return _database!;

    // Initialize database with version 5 schema
    _database = await _initDB('kmy_app.db');
    return _database!;
  }

  /// Initializes the SQLite database with schema creation.
  ///
  /// Creates the database file in the default app directory
  /// and sets up all required tables with proper relationships.
  ///
  /// Parameters:
  /// - [fileName]: Name of the database file
  ///
  /// Returns the initialized [Database] instance.
  Future<Database> _initDB(String fileName) async {
    // Get the default database directory path
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 6,
      onCreate: _createDB,
      // Handle database schema migrations
      onUpgrade: (db, oldVersion, newVersion) async {
        // Migration v1->v2: Add closed column to accounts table
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE accounts ADD COLUMN closed INTEGER DEFAULT 0',
          );
        }

        // Migration v2->v3: Add schedules table
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE schedules (
              id TEXT PRIMARY KEY,
              group_key TEXT NOT NULL,
              name TEXT NOT NULL,
              account_id TEXT NOT NULL,
              currency_id TEXT NOT NULL,
              payee TEXT NOT NULL,
              frequency TEXT NOT NULL,
              payment_method TEXT NOT NULL,
              next_due_date TEXT NOT NULL,
              amount_num TEXT NOT NULL,
              amount_denom TEXT NOT NULL
            )
          ''');
        }

        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE payees (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL
            )
          ''');
        }

        if (oldVersion < 6) {
          await db.execute('DROP TABLE IF EXISTS splits');
          await db.execute('DROP TABLE IF EXISTS transactions');
          await db.execute('DROP TABLE IF EXISTS schedules');
          await db.execute('DROP TABLE IF EXISTS payees');
          await db.execute('DROP TABLE IF EXISTS accounts');

          await _createDB(db, 6);
        }

        // Migration v4->v5: Add preferred column to accounts table
        if (oldVersion < 5) {
          await db.execute(
            'ALTER TABLE accounts ADD COLUMN preferred INTEGER DEFAULT 0',
          );
        }
      },
    );
  }

  /// Creates the initial database schema.
  ///
  /// Sets up all required tables with proper constraints,
  /// indexes, and foreign key relationships for the KMyMoney app.
  ///
  /// Parameters:
  /// - [db]: The database instance to create tables in
  /// - [version]: The database version number
  Future<void> _createDB(Database db, int version) async {
    // Create accounts table for financial accounts
    await db.execute('''
      CREATE TABLE accounts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        currency_id TEXT NOT NULL,
        closed INTEGER DEFAULT 0,
        preferred INTEGER DEFAULT 0
      )
    ''');

    // Create transactions table for transaction headers
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        post_date TEXT NOT NULL,
        memo TEXT NOT NULL DEFAULT '',
        entry_date TEXT NOT NULL DEFAULT '',
        commodity TEXT NOT NULL DEFAULT '',
        extra_attrs_json TEXT NOT NULL DEFAULT '{}',
        extra_inner_xml TEXT NOT NULL DEFAULT ''
      )
    ''');

    // Create splits table for transaction line items
    await db.execute('''
      CREATE TABLE splits (
        row_id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id TEXT NOT NULL,
        split_id TEXT NOT NULL,
        account_id TEXT NOT NULL,

        value_num TEXT NOT NULL,
        value_denom TEXT NOT NULL,

        shares_num TEXT NOT NULL DEFAULT '0',
        shares_denom TEXT NOT NULL DEFAULT '1',
        price_num TEXT NOT NULL DEFAULT '1',
        price_denom TEXT NOT NULL DEFAULT '1',

        payee_id TEXT NOT NULL DEFAULT '',
        reconcile_date TEXT NOT NULL DEFAULT '',
        reconcile_flag TEXT NOT NULL DEFAULT '0',
        action TEXT NOT NULL DEFAULT '',
        memo TEXT NOT NULL DEFAULT '',
        number TEXT NOT NULL DEFAULT '',
        bankid TEXT NOT NULL DEFAULT '',

        extra_attrs_json TEXT NOT NULL DEFAULT '{}',

        FOREIGN KEY (transaction_id) REFERENCES transactions(id),
        FOREIGN KEY (account_id) REFERENCES accounts(id)
      )
    ''');

    // Add index for faster lookups
    await db.execute(
      'CREATE UNIQUE INDEX splits_tx_split_id_idx ON splits(transaction_id, split_id)',
    );

    // Create schedules table for recurring transactions
    await db.execute('''
      CREATE TABLE schedules (
        id TEXT PRIMARY KEY,
        group_key TEXT NOT NULL,
        name TEXT NOT NULL,
        account_id TEXT NOT NULL,
        currency_id TEXT NOT NULL,
        payee TEXT NOT NULL,
        frequency TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        next_due_date TEXT NOT NULL,
        amount_num TEXT NOT NULL,
        amount_denom TEXT NOT NULL
      )
    ''');

    // Create payees table for transaction recipients
    await db.execute('''
      CREATE TABLE payees (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL
      )
    ''');
  }
}
