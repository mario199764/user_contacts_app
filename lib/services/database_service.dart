import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._();
  static Database? _database;
  final int versionCode = 1;

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
      version: versionCode,
      onCreate: _createDB,
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
        avatar TEXT,
        password TEXT NOT NULL,
        biometry TEXT
      )
    ''');
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

  Future<void> updateAvatar(String email, String avatarPath) async {
    final db = await database;
    await db.update(
      'users',
      {'avatar': avatarPath},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  Future<String?> addUser(Map<String, dynamic> user) async {
    final db = await database;

    //verificar si el email ya existe
    final existingUser = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [user['email']],
    );

    if (existingUser.isNotEmpty) {
      return 'Ya existe un usuario con este email';
    }

    try {
      await db.insert('users', user);
      return null;
    } catch (e) {
      return 'Error al registrar usuario. Por favor inténtalo de nuevo.';
    }
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
