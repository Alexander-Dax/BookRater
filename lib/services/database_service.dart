import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/book.dart';
import '../utils/constants.dart';

/// Service für alle Datenbank-Operationen
class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  /// Lazy-Init: Datenbank wird erst beim ersten Zugriff erstellt
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialisiert die Datenbank
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, databaseName);

    return await openDatabase(
      path,
      version: databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Erstellt die Tabellen bei der ersten Installation
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $booksTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titel TEXT NOT NULL,
        autor TEXT,
        isbn TEXT,
        wortzahl INTEGER,
        jahr_gelesen INTEGER,
        meta TEXT,
        rating REAL NOT NULL,
        cover_url TEXT,
        media_type TEXT NOT NULL DEFAULT 'book',
        mal_id TEXT
      )
    ''');
  }

  /// Migriert die Datenbank bei Version-Updates
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration von Version 1 auf 2: ISBN und Cover-URL hinzufügen
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $booksTable ADD COLUMN isbn TEXT');
      await db.execute('ALTER TABLE $booksTable ADD COLUMN cover_url TEXT');
    }

    // Migration von Version 2 auf 3: Manga-Support (media_type, mal_id)
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE $booksTable ADD COLUMN media_type TEXT NOT NULL DEFAULT \'book\'');
      await db.execute('ALTER TABLE $booksTable ADD COLUMN mal_id TEXT');
    }
  }

  // =========================================================================
  // CRUD-Operationen
  // =========================================================================

  /// Fügt ein neues Buch hinzu und gibt die ID zurück
  Future<int> insertBook(Book book) async {
    final db = await database;
    return await db.insert(booksTable, book.toMap());
  }

  /// Lädt alle Bücher, sortiert nach Rating (beste zuerst)
  Future<List<Book>> getAllBooks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      booksTable,
      orderBy: 'rating DESC',
    );
    return maps.map((map) => Book.fromMap(map)).toList();
  }

  /// Lädt alle Bücher, sortiert nach Rating (schlechteste zuerst - für Algorithmus)
  Future<List<Book>> getAllBooksAscending() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      booksTable,
      orderBy: 'rating ASC',
    );
    return maps.map((map) => Book.fromMap(map)).toList();
  }

  /// Lädt ein einzelnes Buch anhand der ID
  Future<Book?> getBook(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      booksTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Book.fromMap(maps.first);
  }

  /// Aktualisiert ein bestehendes Buch
  Future<int> updateBook(Book book) async {
    final db = await database;
    return await db.update(
      booksTable,
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  /// Löscht ein Buch
  Future<int> deleteBook(int id) async {
    final db = await database;
    return await db.delete(
      booksTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Aktualisiert die Ratings mehrerer Bücher auf einmal (für Re-Spacing)
  Future<void> updateRatings(List<Book> books) async {
    final db = await database;
    final batch = db.batch();

    for (final book in books) {
      batch.update(
        booksTable,
        {'rating': book.rating},
        where: 'id = ?',
        whereArgs: [book.id],
      );
    }

    await batch.commit(noResult: true);
  }

  /// Löscht alle Bücher (für Import)
  Future<void> deleteAllBooks() async {
    final db = await database;
    await db.delete(booksTable);
  }

  /// Zählt die Anzahl der Bücher
  Future<int> getBookCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $booksTable');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Schließt die Datenbank
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
