// lib/core/services/local/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseService {
  static Database? _database;
  static DatabaseService? _instance;

  DatabaseService._internal();
  
  factory DatabaseService() {
    _instance ??= DatabaseService._internal();
    return _instance!;
  }

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
    // ===== USERS TABLE =====
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        start_date TEXT NOT NULL,
        total_days INTEGER DEFAULT 390,
        buffer_days INTEGER DEFAULT 30,
        daily_goal INTEGER DEFAULT 4,
        weekly_off TEXT DEFAULT 'Sunday',
        created_at TEXT NOT NULL
      )
    ''');

    // ===== SYLLABUS TABLE =====
    await db.execute('''
      CREATE TABLE syllabus (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        day_number INTEGER NOT NULL,
        date TEXT NOT NULL,
        topics TEXT NOT NULL, -- JSON array
        status TEXT NOT NULL, -- PENDING, COMPLETED, OFF_DAY, RESCHEDULED, MERGED, BUFFERED
        completed_topics TEXT, -- JSON array
        hours_spent INTEGER DEFAULT 0,
        reason TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // ===== PROGRESS TABLE =====
    await db.execute('''
      CREATE TABLE progress (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        date TEXT NOT NULL,
        topics_completed INTEGER DEFAULT 0,
        topics_total INTEGER DEFAULT 0,
        streak INTEGER DEFAULT 0,
        consistency REAL DEFAULT 0.0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // ===== CHAT HISTORY TABLE =====
    await db.execute('''
      CREATE TABLE chat_history (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        session_id TEXT NOT NULL,
        message TEXT NOT NULL,
        response TEXT NOT NULL,
        topic TEXT,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // ===== QUIZZES TABLE =====
    await db.execute('''
      CREATE TABLE quizzes (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        day_number INTEGER NOT NULL,
        questions TEXT NOT NULL, -- JSON array
        score INTEGER DEFAULT 0,
        completed INTEGER DEFAULT 0, -- 0=false, 1=true
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // ===== INDEXES =====
    await db.execute('''
      CREATE INDEX idx_syllabus_date ON syllabus(date);
      CREATE INDEX idx_syllabus_status ON syllabus(status);
      CREATE INDEX idx_progress_date ON progress(date);
      CREATE INDEX idx_chat_timestamp ON chat_history(timestamp);
    ''');

    // ===== INITIAL DATA =====
    await _insertInitialData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle migrations here
    if (oldVersion < 2) {
      // await db.execute('ALTER TABLE syllabus ADD COLUMN new_column TEXT');
    }
  }

  Future<void> _insertInitialData(Database db) async {
    // Insert default user if needed
    // await db.insert('users', {
    //   'id': 'default_user',
    //   'name': 'Test User',
    //   ...
    // });
  }
}