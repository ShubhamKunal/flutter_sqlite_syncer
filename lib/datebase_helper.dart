import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:developer' as developer;

class PermanentDB {
  static Database? _database;
  final String tableName = 'contacts';

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'contacts.db');
    developer.log(path);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT,
            age INTEGER
          )
        ''');
      },
    );
  }

  Future<int> insert(Map<String, dynamic> contact) async {
    final db = await database;
    return await db.insert(tableName, contact);
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    final db = await database;

    return await db.query(tableName);
  }

  Future<int> update(Map<String, dynamic> contact) async {
    final db = await database;
    return await db.update(
      tableName,
      contact,
      where: 'id = ?',
      whereArgs: [contact['id']],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAll() async {
    final db = await database;
    return await db.delete(tableName);
  }
}

class TemporaryDB {
  static Database? _database;
  final String tableName = 'temp_contacts';

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'temp_contacts.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT,
            age INTEGER
          )
        ''');
      },
    );
  }

  Future<int> insert(Map<String, dynamic> contact) async {
    final db = await database;
    return await db.insert(tableName, contact);
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    final db = await database;

    return await db.query(tableName);
  }

  Future<int> update(Map<String, dynamic> contact) async {
    final db = await database;
    return await db.update(
      tableName,
      contact,
      where: 'id = ?',
      whereArgs: [contact['id']],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAll() async {
    final db = await database;
    return await db.delete(tableName);
  }
}
