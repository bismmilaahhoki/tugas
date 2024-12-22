import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get _db async {
    final path = await getDatabasesPath();
    return openDatabase(join(path, 'expense_tracker.db'));
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expense_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String path) async {
    final dbPath = await getDatabasesPath();
    final fullPath = join(dbPath, path);
    return await openDatabase(fullPath, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Create the 'users' table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    // Insert the default user (andi / andi123) if the users table is empty
    await _insertDefaultUser(db);
  }

  Future _insertDefaultUser(Database db) async {
    // Check if the user table is empty
    final result = await db.query('users');
    if (result.isEmpty) {
      // Insert default user if the table is empty
      await db.insert('users', {
        'username': 'user',
        'password': 'user123',
      });
    }
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUser(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
