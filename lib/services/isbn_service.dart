import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service für ISBN-Lookup über Open Library API
class IsbnService {
  static final IsbnService instance = IsbnService._internal();
  IsbnService._internal();

  /// Sucht Buchinformationen basierend auf ISBN
  ///
  /// Gibt eine Map mit {title, author, isbn} zurück oder null bei Fehler
  Future<Map<String, String>?> lookupByIsbn(String isbn) async {
    try {
      // Bereinige ISBN (entferne Bindestriche und Leerzeichen)
      final cleanIsbn = isbn.replaceAll(RegExp(r'[-\s]'), '');

      // Open Library API: https://openlibrary.org/dev/docs/api/books
      final url = Uri.parse('https://openlibrary.org/api/books?bibkeys=ISBN:$cleanIsbn&format=json&jscmd=data');

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout beim Abrufen der Buchdaten');
        },
      );

      if (response.statusCode != 200) {
        // HTTP Fehler bei ISBN Lookup
        return null;
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final key = 'ISBN:$cleanIsbn';

      if (!data.containsKey(key)) {
        // Keine Daten für diese ISBN gefunden
        return null;
      }

      final bookData = data[key] as Map<String, dynamic>;

      // Extrahiere Titel
      final title = bookData['title'] as String?;
      if (title == null) {
        return null;
      }

      // Extrahiere Autor(en)
      String? author;
      if (bookData.containsKey('authors')) {
        final authors = bookData['authors'] as List;
        if (authors.isNotEmpty) {
          final authorData = authors[0] as Map<String, dynamic>;
          author = authorData['name'] as String?;
        }
      }

      // Extrahiere Cover-URL (falls vorhanden)
      String? coverUrl;
      if (bookData.containsKey('cover')) {
        final cover = bookData['cover'] as Map<String, dynamic>;
        coverUrl = cover['large'] as String? ?? cover['medium'] as String?;
      }

      final result = <String, String>{
        'title': title,
        'isbn': cleanIsbn,
      };

      if (author != null) result['author'] = author;
      if (coverUrl != null) result['coverUrl'] = coverUrl;

      return result;
    } catch (e) {
      // Fehler beim ISBN Lookup (z.B. Netzwerkfehler)
      return null;
    }
  }

  /// Alternative: Google Books API (als Fallback)
  Future<Map<String, String>?> lookupByIsbnGoogle(String isbn) async {
    try {
      final cleanIsbn = isbn.replaceAll(RegExp(r'[-\s]'), '');
      final url = Uri.parse('https://www.googleapis.com/books/v1/volumes?q=isbn:$cleanIsbn');

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout beim Abrufen der Buchdaten');
        },
      );

      if (response.statusCode != 200) {
        return null;
      }

      final data = json.decode(response.body) as Map<String, dynamic>;

      if (data['totalItems'] == 0) {
        return null;
      }

      final items = data['items'] as List;
      final volumeInfo = items[0]['volumeInfo'] as Map<String, dynamic>;

      final title = volumeInfo['title'] as String?;
      if (title == null) {
        return null;
      }

      String? author;
      if (volumeInfo.containsKey('authors')) {
        final authors = volumeInfo['authors'] as List;
        if (authors.isNotEmpty) {
          author = authors[0] as String;
        }
      }

      String? coverUrl;
      if (volumeInfo.containsKey('imageLinks')) {
        final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>;
        coverUrl = imageLinks['thumbnail'] as String? ?? imageLinks['smallThumbnail'] as String?;
      }

      final result = <String, String>{
        'title': title,
        'isbn': cleanIsbn,
      };

      if (author != null) result['author'] = author;
      if (coverUrl != null) result['coverUrl'] = coverUrl;

      return result;
    } catch (e) {
      // Fehler beim Google Books Lookup (z.B. Netzwerkfehler)
      return null;
    }
  }

  /// Lookup mit Fallback: Versuche zuerst Open Library, dann Google Books
  Future<Map<String, String>?> lookup(String isbn) async {
    // Versuche zuerst Open Library
    final result = await lookupByIsbn(isbn) ??
                   // Fallback zu Google Books
                   await lookupByIsbnGoogle(isbn);

    return result;
  }
}
