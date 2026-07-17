import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/book.dart';
import 'database_service.dart';
import 'rating_service.dart';

/// Service für CSV Import/Export von Büchern
class CsvService {
  static final CsvService instance = CsvService._internal();
  CsvService._internal();

  final DatabaseService _db = DatabaseService.instance;

  /// Exportiert alle Bücher als CSV-Datei
  ///
  /// Format: titel,autor,isbn,jahr_gelesen,rating,meta
  Future<String?> exportToCSV() async {
    try {
      // Hole alle Bücher
      final books = await _db.getAllBooks();

      if (books.isEmpty) {
        // Keine Bücher zum Exportieren vorhanden
        return null;
      }

      // CSV Header
      final lines = <String>[];
      lines.add('titel,autor,isbn,jahr_gelesen,rating,meta');

      // Bücher als CSV-Zeilen
      for (final book in books) {
        final line = [
          _escapeCsv(book.titel),
          _escapeCsv(book.autor ?? ''),
          _escapeCsv(book.isbn ?? ''),
          book.jahrGelesen?.toString() ?? '',
          book.rating.toString(),
          _escapeCsv(book.meta ?? ''),
        ].join(',');
        lines.add(line);
      }

      // Speichere CSV-Datei
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final filePath = '${directory.path}/books_export_$timestamp.csv';
      final file = File(filePath);
      await file.writeAsString(lines.join('\n'));

      // CSV erfolgreich exportiert
      return filePath;
    } catch (e) {
      // Fehler beim CSV-Export
      return null;
    }
  }

  /// Importiert Bücher aus einer CSV-Datei
  ///
  /// - Überschreibt Bücher mit gleichem Titel
  /// - Behält andere Bücher
  /// - Sortiert alle Bücher neu
  Future<ImportResult> importFromCSV() async {
    try {
      // Datei auswählen
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.isEmpty) {
        return ImportResult(success: false, message: 'Keine Datei ausgewählt');
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        return ImportResult(success: false, message: 'Dateipfad ungültig');
      }

      // CSV-Datei lesen
      final file = File(filePath);
      final content = await file.readAsString();
      final lines = content.split('\n').where((line) => line.trim().isNotEmpty).toList();

      if (lines.isEmpty) {
        return ImportResult(success: false, message: 'CSV-Datei ist leer');
      }

      // Header überspringen
      if (lines.length < 2) {
        return ImportResult(success: false, message: 'CSV-Datei enthält keine Daten');
      }

      // Parse CSV-Zeilen
      final importedBooks = <Book>[];
      for (int i = 1; i < lines.length; i++) {
        try {
          final book = _parseCsvLine(lines[i]);
          if (book != null) {
            importedBooks.add(book);
          }
        } catch (e) {
          // Fehler beim Parsen von Zeile - überspringe und fahre fort
        }
      }

      if (importedBooks.isEmpty) {
        return ImportResult(success: false, message: 'Keine gültigen Bücher in CSV gefunden');
      }

      // Hole existierende Bücher
      final existingBooks = await _db.getAllBooks();
      final existingTitles = {for (var book in existingBooks) book.titel.toLowerCase(): book};

      // Lösche Bücher mit gleichen Titeln
      int overwritten = 0;
      for (final importBook in importedBooks) {
        final lowerTitle = importBook.titel.toLowerCase();
        if (existingTitles.containsKey(lowerTitle)) {
          final existingBook = existingTitles[lowerTitle]!;
          await _db.deleteBook(existingBook.id!);
          overwritten++;
        }
      }

      // Füge importierte Bücher hinzu (ohne ID, damit neue IDs vergeben werden)
      for (final book in importedBooks) {
        await _db.insertBook(Book(
          titel: book.titel,
          autor: book.autor,
          isbn: book.isbn,
          jahrGelesen: book.jahrGelesen,
          rating: book.rating,
          meta: book.meta,
        ));
      }

      // Neu sortieren: Alle Bücher holen und Ratings neu berechnen
      final allBooks = await _db.getAllBooks();
      final updatedBooks = RatingService.respaceRatings(allBooks);

      // Ratings in Datenbank aktualisieren
      for (final book in updatedBooks) {
        await _db.updateBook(book);
      }

      return ImportResult(
        success: true,
        message: '${importedBooks.length} Bücher importiert ($overwritten überschrieben)',
        imported: importedBooks.length,
        overwritten: overwritten,
      );
    } catch (e) {
      // Fehler beim CSV-Import
      return ImportResult(success: false, message: 'Fehler: $e');
    }
  }

  /// Hilfsfunktion: CSV-Escape (Anführungszeichen bei Kommas)
  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Hilfsfunktion: Parse eine CSV-Zeile zu einem Book
  Book? _parseCsvLine(String line) {
    final fields = _parseCsvFields(line);

    if (fields.length < 7) {
      // Ungültige Zeile (zu wenige Felder)
      return null;
    }

    final titel = fields[0].trim();
    if (titel.isEmpty) {
      // Titel fehlt in Zeile
      return null;
    }

    try {
      return Book(
        titel: titel,
        autor: fields[1].trim().isEmpty ? null : fields[1].trim(),
        isbn: fields[2].trim().isEmpty ? null : fields[2].trim(),
        jahrGelesen: fields[3].trim().isEmpty ? null : int.tryParse(fields[3].trim()),
        rating: double.parse(fields[4].trim()),
        meta: fields.length > 5 && fields[5].trim().isNotEmpty ? fields[5].trim() : null,
      );
    } catch (e) {
      // Fehler beim Parsen der Zeile (z.B. ungültiges Rating-Format)
      return null;
    }
  }

  /// Hilfsfunktion: Parse CSV-Felder (unterstützt Quotes)
  List<String> _parseCsvFields(String line) {
    final fields = <String>[];
    bool inQuotes = false;
    StringBuffer currentField = StringBuffer();

    for (int i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          // Escaped quote ("")
          currentField.write('"');
          i++; // Skip next quote
        } else {
          // Toggle quotes
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        // Field separator
        fields.add(currentField.toString());
        currentField = StringBuffer();
      } else {
        currentField.write(char);
      }
    }

    // Add last field
    fields.add(currentField.toString());

    return fields;
  }
}

/// Ergebnis eines CSV-Imports
class ImportResult {
  final bool success;
  final String message;
  final int imported;
  final int overwritten;

  ImportResult({
    required this.success,
    required this.message,
    this.imported = 0,
    this.overwritten = 0,
  });
}
