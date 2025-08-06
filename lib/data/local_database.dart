import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;

  LocalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('favorite_movies.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorite_movies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        genre TEXT NOT NULL,
        rating INTEGER NOT NULL,
        description TEXT,
        posterPath TEXT,
        releaseDate TEXT
      )
    ''');
  }

  Future<int> insertMovie(Map<String, dynamic> movie) async {
    final db = await instance.database;
    return await db.insert('favorite_movies', movie);
  }

  Future<List<Map<String, dynamic>>> getAllMovies() async {
    final db = await instance.database;
    return await db.query('favorite_movies');
  }

  Future<int> updateMovie(int id, Map<String, dynamic> movie) async {
    final db = await instance.database;
    return await db.update('favorite_movies', movie, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteMovie(int id) async {
    final db = await instance.database;
    return await db.delete('favorite_movies', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}