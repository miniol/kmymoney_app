import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();

  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('kmy_app.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
      // Migration from version 1 to 2: add closed column to accounts table
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE accounts ADD COLUMN closed INTEGER DEFAULT 0',
          );
        }

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

        if (oldVersion < 5) {
          await db.execute(
            'ALTER TABLE accounts ADD COLUMN preferred INTEGER DEFAULT 0',
          );
        }
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
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

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        post_date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE splits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id TEXT NOT NULL,
        account_id TEXT NOT NULL,
        numerator TEXT NOT NULL,
        denominator TEXT NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES transactions(id),
        FOREIGN KEY (account_id) REFERENCES accounts(id)
      )
    ''');

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

    await db.execute('''
      CREATE TABLE payees (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL
      )
    ''');
  }
}
