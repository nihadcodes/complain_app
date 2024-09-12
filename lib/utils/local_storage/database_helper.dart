import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
    return await openDatabase(
      join(await getDatabasesPath(), 'complaints.db'),
      version: 4,
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE complaints(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            employeeId TEXT, 
            name TEXT, 
            notify TEXT, 
            complainAgainst TEXT,
            complainBasis TEXT, 
            witness TEXT,
            complainDescription TEXT, 
            actionSeek TEXT,
            selectedDate TEXT, 
            imagePath TEXT,
            videoPath TEXT,
            audioPath TEXT
          )
          ''',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute("ALTER TABLE complaints ADD COLUMN videoPath TEXT;");
          await db.execute("ALTER TABLE complaints ADD COLUMN audioPath TEXT;");
        }

        if (oldVersion < 3) {
          await db.execute("ALTER TABLE complaints ADD COLUMN complainBasis TEXT;");


        }
        if (oldVersion < 4) {
          await db.execute("ALTER TABLE complaints ADD COLUMN witness TEXT;");
        }
      },
    );
  }

  Future<void> insertComplaint(Map<String, dynamic> complaint) async {
    final db = await database;
    await db.insert(
      'complaints',
      complaint,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getComplaints() async {
    final db = await database;
    return await db.query('complaints');
  }

  Future<Map<String, dynamic>?> getLatestComplaint() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'complaints',
      orderBy: 'id DESC',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null;
    }
  }

  Future<void> deleteComplaint(int id) async {
    final db = await database;
    await db.delete(
      'complaints',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllComplaints() async {
    final db = await database;
    await db.delete('complaints');
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}
