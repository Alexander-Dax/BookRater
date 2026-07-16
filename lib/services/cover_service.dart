import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/book.dart';
import 'database_service.dart';

/// Service zum Herunterladen von Buchcovern via ISBN
/// Nutzt die Open Library Cover API: https://openlibrary.org/dev/docs/api/covers
class CoverService {
  static final CoverService instance = CoverService._internal();
  CoverService._internal();

  final DatabaseService _db = DatabaseService.instance;

  /// Lädt das Cover für ein Buch herunter (falls ISBN vorhanden)
  ///
  /// Rückgabe: true wenn erfolgreich, false wenn nicht
  Future<bool> downloadCover(Book book) async {
    if (book.isbn == null || book.isbn!.isEmpty) {
      print('Kein ISBN für "${book.titel}"');
      return false;
    }

    // ISBN bereinigen (nur Zahlen)
    final isbn = book.isbn!.replaceAll(RegExp(r'[^0-9]'), '');

    if (isbn.isEmpty) {
      print('Ungültige ISBN: ${book.isbn}');
      return false;
    }

    // Open Library Cover API URLs (versuche verschiedene Größen)
    final sizes = ['L', 'M', 'S']; // Large, Medium, Small

    for (final size in sizes) {
      final url = 'https://covers.openlibrary.org/b/isbn/$isbn-$size.jpg';

      try {
        print('Versuche Cover-Download: $url');
        final response = await http.get(Uri.parse(url)).timeout(
          const Duration(seconds: 10),
        );

        if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
          // Prüfe ob es tatsächlich ein Bild ist (nicht die "no cover" Placeholder)
          if (response.bodyBytes.length < 1000) {
            continue; // Zu klein, wahrscheinlich Placeholder
          }

          // Speichere das Bild lokal
          final appDir = await getApplicationDocumentsDirectory();
          final coversDir = Directory('${appDir.path}/covers');
          if (!await coversDir.exists()) {
            await coversDir.create(recursive: true);
          }

          final filename = '${book.id}_$isbn.jpg';
          final file = File('${coversDir.path}/$filename');
          await file.writeAsBytes(response.bodyBytes);

          // Update das Buch in der Datenbank
          final updatedBook = book.copyWith(coverUrl: file.path);
          await _db.updateBook(updatedBook);

          print('Cover gespeichert: ${file.path}');
          return true;
        }
      } catch (e) {
        print('Fehler beim Cover-Download ($size): $e');
        continue;
      }
    }

    print('Kein Cover gefunden für ISBN: $isbn');
    return false;
  }

  /// Lädt Cover für mehrere Bücher herunter (mit Pause zwischen Requests)
  Future<int> downloadCoversForBooks(List<Book> books) async {
    int successCount = 0;

    for (final book in books) {
      if (book.isbn != null && book.isbn!.isNotEmpty && book.coverUrl == null) {
        final success = await downloadCover(book);
        if (success) successCount++;

        // Warte 500ms zwischen Requests (höflich zur API)
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    return successCount;
  }

  /// Löscht das Cover-Bild eines Buches
  Future<void> deleteCover(Book book) async {
    if (book.coverUrl == null) return;

    try {
      final file = File(book.coverUrl!);
      if (await file.exists()) {
        await file.delete();
        print('Cover gelöscht: ${book.coverUrl}');
      }

      // Update Datenbank
      final updatedBook = book.copyWith(coverUrl: null);
      await _db.updateBook(updatedBook);
    } catch (e) {
      print('Fehler beim Löschen des Covers: $e');
    }
  }

  /// Prüft ob ein Cover existiert
  Future<bool> coverExists(Book book) async {
    if (book.coverUrl == null) return false;
    final file = File(book.coverUrl!);
    return await file.exists();
  }
}
