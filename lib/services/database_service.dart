import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;
  DatabaseService._internal();

  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'school_management.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

 
  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE admins (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        fullName TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE teachers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        subject TEXT,
        username TEXT UNIQUE,
        password TEXT,
        isHead INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE classes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        gradeLevel TEXT,
        capacity INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        username TEXT UNIQUE,
        password TEXT,
        gradeLevel TEXT,
        classId INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE subjects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE class_teacher (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        classId INTEGER,
        teacherId INTEGER,
        subject TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE schedule (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        classId INTEGER,
        teacherId INTEGER,
        subjectId INTEGER,
        dayOfWeek TEXT,
        period INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE grades (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId INTEGER,
        teacherId INTEGER,
        subjectId INTEGER,
        grade REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId INTEGER,
        teacherId INTEGER,
        subjectId INTEGER,
        date TEXT,
        status TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT,
        createdBy INTEGER,
        createdAt TEXT
      )
    ''');

  ة
    for (final s in ['عربي', 'حساب', 'انجليزي', 'علوم', 'دين', 'دراسات']) {
      await db.insert('subjects', {'name': s});
    }

    await db.insert('admins', {
      'username': 'mohamed esam',
      'password': '1234',
      'fullName': 'Mohamed Esam',
    });
  }

  Future<void> _onUpgrade(Database db, int oldV, int newV) async {
    if (oldV < 2) {
      await db.execute(
        'ALTER TABLE teachers ADD COLUMN isHead INTEGER DEFAULT 0',
      );
    }
  }

 
  Future<Map<String, dynamic>?> getAdmin(String u, String p) async {
    final db = await database;
    final r = await db.query(
      'admins',
      where: 'username=? AND password=?',
      whereArgs: [u, p],
    );
    return r.isNotEmpty ? r.first : null;
  }

  Future<Map<String, dynamic>?> getTeacher(String u, String p) async {
    final db = await database;
    final r = await db.query(
      'teachers',
      where: 'username=? AND password=?',
      whereArgs: [u, p],
    );
    return r.isNotEmpty ? r.first : null;
  }

  Future<Map<String, dynamic>?> getStudent(String u, String p) async {
    final db = await database;
    final r = await db.query(
      'students',
      where: 'username=? AND password=?',
      whereArgs: [u, p],
    );
    return r.isNotEmpty ? r.first : null;
  }

 
  Future<int> addTeacher(
      String name, String subject, String username, String password) async {
    final db = await database;
    return db.insert('teachers', {
      'name': name,
      'subject': subject,
      'username': username,
      'password': password,
    });
  }

  Future<int> addStudent(
      String name,
      String username,
      String password,
      String grade,
      int classId) async {
    final db = await database;
    return db.insert('students', {
      'name': name,
      'username': username,
      'password': password,
      'gradeLevel': grade,
      'classId': classId,
    });
  }

  Future<int> addClass(
      String name, String gradeLevel, int capacity) async {
    final db = await database;
    return db.insert('classes', {
      'name': name,
      'gradeLevel': gradeLevel,
      'capacity': capacity,
    });
  }

  Future<void> deleteClass(int id) async {
    final db = await database;
    await db.delete(
      'classes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAllTeachers() async {
    final db = await database;
    return db.query('teachers');
  }

  Future<List<Map<String, dynamic>>> getAllStudents() async {
    final db = await database;
    return db.query('students');
  }

  Future<List<Map<String, dynamic>>> getAllClasses() async {
    final db = await database;
    return db.query('classes');
  }

  Future<List<Map<String, dynamic>>> getAllSubjects() async {
    final db = await database;
    return db.query('subjects');
  }

  Future<void> assignTeacherToClass(
      int classId, int teacherId, String subject) async {
    final db = await database;
    await db.insert('class_teacher', {
      'classId': classId,
      'teacherId': teacherId,
      'subject': subject,
    });
  }

  Future<List<Map<String, dynamic>>> getTeacherClasses(int teacherId) async {
    final db = await database;
    return db.rawQuery('''
      SELECT c.*
      FROM classes c
      JOIN class_teacher ct ON ct.classId = c.id
      WHERE ct.teacherId = ?
    ''', [teacherId]);
  }

  Future<List<Map<String, dynamic>>> getClassStudents(int classId) async {
    final db = await database;
    return db.query('students', where: 'classId=?', whereArgs: [classId]);
  }

  Future<int> getSubjectIdByName(String name) async {
    final db = await database;
    final r =
    await db.query('subjects', where: 'name=?', whereArgs: [name]);
    return r.first['id'] as int;
  }

  Future<void> addGrade(
      int studentId, int teacherId, int subjectId, double grade) async {
    final db = await database;
    await db.insert('grades', {
      'studentId': studentId,
      'teacherId': teacherId,
      'subjectId': subjectId,
      'grade': grade,
    });
  }

  Future<void> addAttendance(
      int studentId,
      int teacherId,
      int subjectId,
      String date,
      String status) async {
    final db = await database;
    await db.insert('attendance', {
      'studentId': studentId,
      'teacherId': teacherId,
      'subjectId': subjectId,
      'date': date,
      'status': status,
    });
  }

  Future<bool> hasAttendanceForDay(
      int studentId, int subjectId, String date) async {
    final db = await database;
    final r = await db.query(
      'attendance',
      where: 'studentId=? AND subjectId=? AND date=?',
      whereArgs: [studentId, subjectId, date],
    );
    return r.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getStudentGrades(int studentId) async {
    final db = await database;
    return db.rawQuery('''
      SELECT g.grade, s.name AS subject
      FROM grades g
      JOIN subjects s ON g.subjectId = s.id
      WHERE g.studentId = ?
    ''', [studentId]);
  }

  Future<List<Map<String, dynamic>>> getStudentAttendance(int studentId) async {
    final db = await database;
    return db.rawQuery('''
      SELECT a.date, a.status, s.name AS subject
      FROM attendance a
      JOIN subjects s ON a.subjectId = s.id
      WHERE a.studentId = ?
    ''', [studentId]);
  }

  Future<List<Map<String, dynamic>>> getClassSchedule(int classId) async {
    final db = await database;
    return db.rawQuery('''
      SELECT sc.dayOfWeek, sc.period, t.name AS teacher, s.name AS subject
      FROM schedule sc
      JOIN teachers t ON sc.teacherId = t.id
      JOIN subjects s ON sc.subjectId = s.id
      WHERE sc.classId = ?
    ''', [classId]);
  }

  Future<void> addSchedule(
      int classId,
      int teacherId,
      int subjectId,
      String day,
      int period) async {
    final db = await database;
    await db.insert('schedule', {
      'classId': classId,
      'teacherId': teacherId,
      'subjectId': subjectId,
      'dayOfWeek': day,
      'period': period,
    });
  }

  Future<void> addNotification(
      String title, String content, int createdBy) async {
    final db = await database;
    await db.insert('notifications', {
      'title': title,
      'content': content,
      'createdBy': createdBy,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getStudentNotifications() async {
    final db = await database;
    return db.query('notifications', orderBy: 'createdAt DESC');
  }
}
