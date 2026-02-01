import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:habit_tracker/core/constants/app_constants.dart';

/// Database Helper for SQLite operations
class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create tables
  Future<void> _onCreate(Database db, int version) async {
    // Users table (cached current user)
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        firebase_uid TEXT NOT NULL,
        email TEXT NOT NULL,
        display_name TEXT,
        timezone TEXT DEFAULT 'UTC',
        notification_enabled INTEGER DEFAULT 1,
        morning_reminder_time TEXT DEFAULT '06:00:00',
        evening_reminder_time TEXT DEFAULT '21:00:00',
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Habits table
    await db.execute('''
      CREATE TABLE habits (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        category TEXT DEFAULT 'personal',
        frequency TEXT DEFAULT 'daily',
        is_active INTEGER DEFAULT 1,
        is_learning_habit INTEGER DEFAULT 0,
        color TEXT DEFAULT '#424242',
        icon TEXT DEFAULT 'check',
        reminder_time TEXT,
        current_streak INTEGER DEFAULT 0,
        longest_streak INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Daily logs table
    await db.execute('''
      CREATE TABLE daily_logs (
        id TEXT PRIMARY KEY,
        habit_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        log_date TEXT NOT NULL,
        completed INTEGER DEFAULT 0,
        learning_note TEXT,
        completed_at TEXT,
        created_at TEXT,
        updated_at TEXT,
        synced INTEGER DEFAULT 0,
        UNIQUE(habit_id, log_date)
      )
    ''');

    // Streaks table
    await db.execute('''
      CREATE TABLE streaks (
        id TEXT PRIMARY KEY,
        habit_id TEXT NOT NULL UNIQUE,
        user_id TEXT NOT NULL,
        current_streak INTEGER DEFAULT 0,
        longest_streak INTEGER DEFAULT 0,
        last_completed_date TEXT,
        updated_at TEXT
      )
    ''');

    // Reports table (cached)
    await db.execute('''
      CREATE TABLE reports (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        report_month TEXT NOT NULL,
        report_content TEXT NOT NULL,
        skills_learned TEXT,
        generated_at TEXT,
        UNIQUE(user_id, report_month)
      )
    ''');

    // Revision habits table
    await db.execute('''
      CREATE TABLE revision_habits (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        original_skill TEXT NOT NULL,
        source_month TEXT NOT NULL,
        duration_days INTEGER DEFAULT 7,
        daily_duration_minutes INTEGER DEFAULT 60,
        status TEXT DEFAULT 'pending',
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Sync queue table
    await db.execute('''
      CREATE TABLE sync_queue (
        id TEXT PRIMARY KEY,
        action TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        payload TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create indexes
    await db.execute(
        'CREATE INDEX idx_habits_user_id ON habits(user_id)');
    await db.execute(
        'CREATE INDEX idx_daily_logs_habit_date ON daily_logs(habit_id, log_date)');
    await db.execute(
        'CREATE INDEX idx_daily_logs_user_date ON daily_logs(user_id, log_date)');
    await db.execute(
        'CREATE INDEX idx_sync_queue_entity ON sync_queue(entity_type, entity_id)');
  }

  /// Upgrade database
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle migrations for future versions
  }

  /// Clear all data (for logout)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('users');
    await db.delete('habits');
    await db.delete('daily_logs');
    await db.delete('streaks');
    await db.delete('reports');
    await db.delete('revision_habits');
    await db.delete('sync_queue');
  }

  /// Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

