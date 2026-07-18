import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service für die Integration mit MyAnimeList (MAL) über die Jikan API
/// Ermöglicht das Suchen und Abrufen von Manga-Informationen
class MalService {
  static final MalService instance = MalService._internal();
  MalService._internal();

  static const String baseUrl = 'https://api.jikan.moe/v4';
  static const Duration requestDelay = Duration(milliseconds: 1000); // Rate limiting
  DateTime? _lastRequest;

  /// Wartet bei Bedarf, um Rate-Limiting einzuhalten
  Future<void> _respectRateLimit() async {
    if (_lastRequest != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequest!);
      if (timeSinceLastRequest < requestDelay) {
        await Future.delayed(requestDelay - timeSinceLastRequest);
      }
    }
    _lastRequest = DateTime.now();
  }

  /// Sucht nach Manga anhand eines Suchbegriffs
  /// Gibt eine Liste von Suchergebnissen zurück
  Future<List<MangaSearchResult>> searchManga(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      await _respectRateLimit();

      final url = Uri.parse('$baseUrl/manga?q=${Uri.encodeComponent(query)}&limit=10');
      final response = await http.get(url);

      // Debug: Response-Details ausgeben
      debugPrint('MAL API Request: $url');
      debugPrint('MAL API Status: ${response.statusCode}');
      debugPrint('MAL API Response: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['data'] ?? [];

        return results.map((item) {
          return MangaSearchResult(
            malId: item['mal_id'].toString(),
            title: item['title'] as String? ?? 'Unbekannt',
            titleEnglish: item['title_english'] as String?,
            imageUrl: item['images']?['jpg']?['image_url'] as String?,
            authors: _extractAuthors(item['authors']),
            synopsis: item['synopsis'] as String?,
            volumes: item['volumes']?.toString(),
            score: item['score']?.toDouble(),
          );
        }).toList();
      } else if (response.statusCode == 504 || response.statusCode == 503) {
        // Jikan API oder MyAnimeList nicht erreichbar
        throw Exception('MyAnimeList ist momentan nicht erreichbar. Bitte später erneut versuchen.');
      } else if (response.statusCode == 429) {
        // Rate limit erreicht
        throw Exception('Zu viele Anfragen. Bitte warten Sie einen Moment.');
      } else {
        // Anderer Fehler
        throw Exception('Fehler bei der Suche (Status ${response.statusCode})');
      }
    } catch (e) {
      // Netzwerkfehler oder Parsing-Fehler - werfe Exception weiter
      rethrow;
    }
  }

  /// Ruft detaillierte Informationen zu einem Manga ab
  Future<Map<String, String?>> getMangaDetails(String malId) async {
    try {
      await _respectRateLimit();

      final url = Uri.parse('$baseUrl/manga/$malId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final mangaData = data['data'];

        return {
          'title': mangaData['title'] as String?,
          'titleEnglish': mangaData['title_english'] as String?,
          'author': _extractAuthors(mangaData['authors']).isNotEmpty
              ? _extractAuthors(mangaData['authors']).first
              : null,
          'imageUrl': mangaData['images']?['jpg']?['large_image_url'] as String?
              ?? mangaData['images']?['jpg']?['image_url'] as String?,
          'synopsis': mangaData['synopsis'] as String?,
          'volumes': mangaData['volumes']?.toString(),
          'score': mangaData['score']?.toString(),
        };
      } else {
        return {};
      }
    } catch (e) {
      return {};
    }
  }

  /// Extrahiert Autorennamen aus der API-Antwort
  List<String> _extractAuthors(dynamic authorsData) {
    if (authorsData == null) return [];
    if (authorsData is! List) return [];

    return authorsData
        .map((author) => author['name'] as String?)
        .where((name) => name != null)
        .cast<String>()
        .toList();
  }
}

/// Datenklasse für ein Manga-Suchergebnis
class MangaSearchResult {
  final String malId;
  final String title;
  final String? titleEnglish;
  final String? imageUrl;
  final List<String> authors;
  final String? synopsis;
  final String? volumes;
  final double? score;

  MangaSearchResult({
    required this.malId,
    required this.title,
    this.titleEnglish,
    this.imageUrl,
    this.authors = const [],
    this.synopsis,
    this.volumes,
    this.score,
  });

  /// Gibt den besten verfügbaren Titel zurück (Englisch falls vorhanden, sonst Original)
  String get bestTitle => titleEnglish ?? title;

  /// Gibt den ersten Autor zurück oder "Unbekannt"
  String get primaryAuthor => authors.isNotEmpty ? authors.first : 'Unbekannt';

  /// Gibt alle Autoren als kommaseperierten String zurück
  String get authorsString => authors.join(', ');
}
