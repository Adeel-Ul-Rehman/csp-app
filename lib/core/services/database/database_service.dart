// lib/core/services/database/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseService {
  static Database? _database;
  static final DatabaseService _instance = DatabaseService._internal();
  
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path;
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      path = 'css_mastery.db';
    } else {
      final directory = await getApplicationDocumentsDirectory();
      path = join(directory.path, 'css_mastery.db');
    }
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users Table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT,
        email TEXT UNIQUE,
        start_date TEXT NOT NULL,
        total_days INTEGER DEFAULT 390,
        buffer_days INTEGER DEFAULT 30,
        daily_goal_hours INTEGER DEFAULT 4,
        weekly_off TEXT DEFAULT 'Sunday',
        created_at TEXT NOT NULL
      )
    ''');

    // Syllabus Table
    await db.execute('''
      CREATE TABLE syllabus (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        day_number INTEGER NOT NULL,
        date TEXT NOT NULL,
        topics TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'PENDING',
        completed_topics TEXT,
        hours_spent INTEGER DEFAULT 0,
        reason TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Progress Table
    await db.execute('''
      CREATE TABLE progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        date TEXT NOT NULL,
        topics_completed INTEGER DEFAULT 0,
        topics_total INTEGER DEFAULT 0,
        streak INTEGER DEFAULT 0,
        consistency REAL DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Topics Table (for better management)
    await db.execute('''
      CREATE TABLE topics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        day_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        is_completed INTEGER DEFAULT 0,
        notes TEXT,
        FOREIGN KEY (day_id) REFERENCES syllabus (id)
      )
    ''');

    // Chat History Table
    await db.execute('''
      CREATE TABLE chat_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        session_id TEXT NOT NULL,
        message TEXT NOT NULL,
        response TEXT NOT NULL,
        topic TEXT,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Create indexes for performance
    await db.execute('CREATE INDEX idx_syllabus_date ON syllabus(date)');
    await db.execute('CREATE INDEX idx_syllabus_status ON syllabus(status)');
    await db.execute('CREATE INDEX idx_progress_date ON progress(date)');
    await db.execute('CREATE INDEX idx_chat_timestamp ON chat_history(timestamp)');

    // Insert default user
    await db.insert('users', {
      'id': 'default_user',
      'name': 'CSS Learner',
      'start_date': DateTime.now().toIso8601String(),
      'total_days': 390,
      'buffer_days': 30,
      'daily_goal_hours': 4,
      'weekly_off': 'Sunday',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns or tables here
    }
  }
}