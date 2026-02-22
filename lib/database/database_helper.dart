import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/employee.dart';
import '../models/request.dart';
import '../models/department.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('office.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE employees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        department TEXT,
        paid REAL
      )
    ''');
    await db.execute('''
      CREATE TABLE requests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        employee_id INTEGER,
        item TEXT,
        price REAL
      )
    ''');
    await db.execute('''
      CREATE TABLE departments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE
      )
    ''');
  }

  // ----------------- Employees -----------------
  Future<int> addEmployee(Employee emp) async {
    final db = await instance.database;
    return await db.insert('employees', emp.toMap());
  }

  Future<int> addRequest(Request req) async {
    final db = await instance.database;
    return await db.insert('requests', req.toMap());
  }

  Future<List<Map<String, dynamic>>> getFullData() async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT e.department, e.id, e.name, e.paid, r.id as rid, r.item, r.price
      FROM employees e
      LEFT JOIN requests r ON e.id = r.employee_id
      ORDER BY e.name
    ''');
  }

  Future<int> updateRequest(Request req) async {
    final db = await instance.database;
    return await db.update(
      'requests',
      req.toMap(),
      where: 'id=?',
      whereArgs: [req.id],
    );
  }

  Future<int> deleteRequest(int id) async {
    final db = await instance.database;
    return await db.delete('requests', where: 'id=?', whereArgs: [id]);
  }

  Future<int> deleteEmployee(int id) async {
    final db = await instance.database;
    await db.delete('requests', where: 'employee_id=?', whereArgs: [id]);
    return await db.delete('employees', where: 'id=?', whereArgs: [id]);
  }

  // ----------------- Departments -----------------
  Future<List<Department>> getDepartments() async {
    final db = await instance.database;
    final res = await db.query('departments', orderBy: 'name');
    return res.map((d) => Department.fromMap(d)).toList();
  }

  Future<int?> addDepartment(String name) async {
    final db = await instance.database;
    try {
      return await db.insert('departments', {'name': name});
    } catch (_) {
      return null;
    }
  }
}
