import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._();
  static Database? _database;

  DatabaseService._();

  factory DatabaseService() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('contacts.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onOpen: (db) async {
        await _checkAndCreateTables(db);
      },
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE contacts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      identification TEXT NOT NULL,
      user_id INTEGER NOT NULL,
      FOREIGN KEY (user_id) REFERENCES users(id)
    )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        avatar TEXT NULLABLE,
        password TEXT NOT NULL
    )
    ''');
  }

  Future<void> _checkAndCreateTables(Database db) async {
    //verificar si la tabla users existe
    var result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='users';");

    if (result.isEmpty) {
      //crear tabla users si no existe
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL
        )
      ''');
    }

    //verificar si la tabla contacts existe
    result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='contacts';");

    if (result.isEmpty) {
      //crear tabla contacts si no existe
      await db.execute('''
        CREATE TABLE contacts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          identification TEXT NOT NULL
        )
      ''');
    }
  }

  Future<Map<String, dynamic>?> validateUser(
      String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE users ADD COLUMN avatar TEXT");
    }
  }

  Future<void> updateAvatar(String email, String avatarPath) async {
    final db = await database;
    await db.update(
      'users',
      {'avatar': avatarPath},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  Future<int> addUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<int> addContact(Map<String, dynamic> contact) async {
    final db = await database;
    return await db.insert('contacts', contact);
  }

  Future<List<Map<String, dynamic>>> fetchContacts(
      {required int userId}) async {
    final db = await database;
    return await db.query(
      'contacts',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> updateContact(int id, Map<String, dynamic> contact) async {
    final db = await database;
    return await db
        .update('contacts', contact, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteContact(int id) async {
    final db = await database;
    return await db.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }
}
