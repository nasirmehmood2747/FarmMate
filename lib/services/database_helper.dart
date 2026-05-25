import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'farmmate.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    // 1. Animals Table
    await db.execute('''
      CREATE TABLE animals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tag_id TEXT,
        type TEXT,
        breed TEXT,
        age TEXT,
        image_path TEXT
      )
    ''');

    // 2. Milk Table (✅ Updated with cow_id)
    await db.execute('''
      CREATE TABLE milk(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        time TEXT,
        liter REAL,
        price REAL,
        cow_id INTEGER -- NULL means "Bulk Entry", Number means "Specific Cow"
      )
    ''');

    // 3. Expenses Table
    await db.execute('''
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        item TEXT,
        amount REAL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _addColumnIfMissing(db, 'milk', 'cow_id', 'INTEGER');
    }
  }

  Future<void> _addColumnIfMissing(
    Database db,
    String table,
    String column,
    String definition,
  ) async {
    final existingColumns = await db.rawQuery('PRAGMA table_info($table)');
    final hasColumn = existingColumns.any((row) => row['name'] == column);

    if (!hasColumn) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $definition');
    }
  }

  // --- ANIMAL FUNCTIONS ---
  Future<int> insertAnimal(Map<String, dynamic> row) async {
    Database db = await _instance.database;
    return await db.insert('animals', row);
  }

  Future<List<Map<String, dynamic>>> getAnimals() async {
    Database db = await _instance.database;
    return await db.query('animals', orderBy: "id DESC");
  }

  Future<int> updateAnimal(Map<String, dynamic> row) async {
    Database db = await _instance.database;
    int id = row['id'];
    return await db.update('animals', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAnimal(int id) async {
    Database db = await _instance.database;
    return await db.delete('animals', where: 'id = ?', whereArgs: [id]);
  }

  // --- MILK FUNCTIONS (✅ Updated) ---

  // Now accepts optional 'cowId'
  Future<int> insertMilk(
    double liters,
    double price,
    String time, {
    int? cowId,
  }) async {
    Database db = await _instance.database;
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    Map<String, dynamic> row = {
      'date': today,
      'time': time,
      'liter': liters,
      'price': price,
      'cow_id': cowId,
    };
    return await db.insert('milk', row);
  }

  // Get total milk for TODAY (Sums both Bulk and Individual entries)
  Future<double> getTodayMilk() async {
    Database db = await _instance.database;
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final result = await db.rawQuery(
      "SELECT SUM(liter) as total FROM milk WHERE date = ?",
      [today],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // ✅ Get Total Milk for ONE Specific Cow (For stats)
  Future<double> getCowTotalMilk(int cowId) async {
    Database db = await _instance.database;
    final result = await db.rawQuery(
      "SELECT SUM(liter) as total FROM milk WHERE cow_id = ?",
      [cowId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}
