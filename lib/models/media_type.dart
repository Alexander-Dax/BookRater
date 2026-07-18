/// Enum für verschiedene Medientypen in der App
/// Unterscheidet zwischen Büchern und Manga-Serien
enum MediaType {
  /// Traditionelles Buch mit ISBN
  book,

  /// Manga-Serie (kann aus mehreren Bänden bestehen)
  manga;

  /// Konvertiert den Enum-Wert in einen String für die Datenbank
  String toJson() => name;

  /// Erstellt einen Enum-Wert aus einem Datenbank-String
  static MediaType fromJson(String json) {
    return MediaType.values.byName(json);
  }

  /// Gibt einen lesbaren deutschen Namen zurück
  String get displayNameDe {
    switch (this) {
      case MediaType.book:
        return 'Buch';
      case MediaType.manga:
        return 'Manga';
    }
  }

  /// Gibt einen lesbaren englischen Namen zurück
  String get displayNameEn {
    switch (this) {
      case MediaType.book:
        return 'Book';
      case MediaType.manga:
        return 'Manga';
    }
  }

  /// Gibt das passende Icon für den Medientyp zurück
  String get iconName {
    switch (this) {
      case MediaType.book:
        return 'book';
      case MediaType.manga:
        return 'auto_stories'; // Book with multiple pages icon
    }
  }
}
