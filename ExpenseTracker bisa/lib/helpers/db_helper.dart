import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Inisialisasi database dan pembukaan koneksi
  Future<Database> get _db async {
    final path = await getDatabasesPath();
    final dbPath = join(path, 'expense_tracker.db');

    // Periksa apakah database sudah ada
    if (_database == null) {
      _database = await openDatabase(
        dbPath,
        version: 1, // Versi database, perubahan versi memanggil _onUpgrade
        onCreate: _createDB,
        onUpgrade: _onUpgrade, // Jika terjadi upgrade versi
      );
    }
    return _database!;
  }

  // Fungsi untuk menangani upgrade database (misalnya jika struktur tabel berubah)
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrade database: $oldVersion -> $newVersion');
    if (oldVersion < 2) {
      // Misalnya jika ingin menambah kolom baru atau melakukan migrasi
      // db.execute("ALTER TABLE transactions ADD COLUMN new_column TEXT");
    }
  }

  // Fungsi untuk menghapus transaksi berdasarkan ID
  Future<int> deleteTransaction(int id) async {
    try {
      final db = await _db;
      // Memastikan tabel ada sebelum mencoba menghapus
      final result = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='transactions'");
      if (result.isEmpty) {
        print('Tabel transactions tidak ditemukan');
        return 0; // Jika tabel tidak ada
      }

      // Menghapus transaksi jika tabel ditemukan
      int deleteResult = await db.delete(
        'transactions',
        where: 'id = ?',
        whereArgs: [id],
      );

      print(
          'Transaksi dengan ID $id berhasil dihapus, baris yang terpengaruh: $deleteResult');
      return deleteResult;
    } catch (e) {
      print('Error saat menghapus transaksi: $e');
      return 0; // Mengembalikan 0 jika terjadi kesalahan
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('transactions.db');
    return _database!;
  }

  Future<Database> _initDB(String path) async {
    final dbPath = await getDatabasesPath();
    final fullPath = join(dbPath, path);
    return await openDatabase(fullPath, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        type TEXT NOT NULL
      ) 
    ''');
  }

  Future<int> insertTransaction(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('transactions', row);
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await instance.database;
    return await db.query('transactions');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // Fungsi untuk menghapus pengeluaran
}
