import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_item.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE tasks (
        id $idType,
        title $textType,
        priority $textType,
        description $textType,
        isCompleted $intType
      )
    ''');
  }
// Insert a new task
  Future<TaskItem> insert(TaskItem task) async {
    final db = await instance.database;
    final id = await db.insert('tasks', task.toJson());
    return task.copyWith(id: id);
  }

  // Retrieve all tasks
  Future<List<TaskItem>> getAllTasks() async {
    final db = await instance.database;
    const orderBy = 'id DESC';
    final result = await db.query('tasks', orderBy: orderBy);
    
    return result.map((json) => TaskItem.fromJson(json)).toList();
  }

  // Update a task
  Future<int> update(TaskItem task) async {
    final db = await instance.database;
    return db.update(
      'tasks',
      task.toJson(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Delete a task (BONUS)
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}