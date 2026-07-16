/// Datenmodell für ein Buch
class Book {
  int? id; // Datenbank-ID (null für neue Bücher)
  String titel;
  String? autor;
  String? isbn; // ISBN-13 oder ISBN-10
  int? wortzahl;
  int? jahrGelesen;
  String? meta;
  double rating;
  String? coverUrl; // URL zum Buchcover (lokal oder remote)

  Book({
    this.id,
    required this.titel,
    this.autor,
    this.isbn,
    this.wortzahl,
    this.jahrGelesen,
    this.meta,
    required this.rating,
    this.coverUrl,
  });

  /// Konvertiert das Buch in eine Map für die Datenbank
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titel': titel,
      'autor': autor,
      'isbn': isbn,
      'wortzahl': wortzahl,
      'jahr_gelesen': jahrGelesen,
      'meta': meta,
      'rating': rating,
      'cover_url': coverUrl,
    };
  }

  /// Erstellt ein Buch aus einer Datenbank-Map
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as int?,
      titel: map['titel'] as String,
      autor: map['autor'] as String?,
      isbn: map['isbn'] as String?,
      wortzahl: map['wortzahl'] as int?,
      jahrGelesen: map['jahr_gelesen'] as int?,
      meta: map['meta'] as String?,
      rating: map['rating'] as double,
      coverUrl: map['cover_url'] as String?,
    );
  }

  /// Erstellt eine Kopie des Buches mit optionalen Änderungen
  Book copyWith({
    int? id,
    String? titel,
    String? autor,
    String? isbn,
    int? wortzahl,
    int? jahrGelesen,
    String? meta,
    double? rating,
    String? coverUrl,
  }) {
    return Book(
      id: id ?? this.id,
      titel: titel ?? this.titel,
      autor: autor ?? this.autor,
      isbn: isbn ?? this.isbn,
      wortzahl: wortzahl ?? this.wortzahl,
      jahrGelesen: jahrGelesen ?? this.jahrGelesen,
      meta: meta ?? this.meta,
      rating: rating ?? this.rating,
      coverUrl: coverUrl ?? this.coverUrl,
    );
  }

  @override
  String toString() {
    return 'Book{id: $id, titel: $titel, autor: $autor, rating: $rating}';
  }
}
