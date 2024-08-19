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
        identification TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
    )
    ''');
  }

  Future<void> _checkAndCreateTables(Database db) async {
    // Verificar si la tabla 'users' existe
    var result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='users';");

    if (result.isEmpty) {
      // Crear tabla 'users' si no existe
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL
        )
      ''');
    }

    // Verificar si la tabla 'contacts' existe
    result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='contacts';");

    if (result.isEmpty) {
      // Crear tabla 'contacts' si no existe
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
      return result
          .first; // Retorna el primer resultado (que contiene username, email y password)
    }
    return null;
  }

  Future<int> addUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<int> addContact(Map<String, dynamic> contact) async {
    final db = await database;
    return await db.insert('contacts', contact);
  }

  Future<List<Map<String, dynamic>>> fetchContacts() async {
    final db = await database;
    return await db.query('contacts');
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
