# Datenmodelle

Dokumentation aller Datenmodelle im BookRater-Projekt.

## Book Model

**Datei**: `lib/models/book.dart`

Das zentrale Datenmodell der Anwendung.

### Felder

```dart
class Book {
  final int? id;              // Auto-Increment Primary Key (nullable für neue Bücher)
  final String titel;         // Buchtitel (Pflichtfeld)
  final String? autor;        // Autor (optional)
  final String? isbn;         // ISBN (optional)
  final int? wortzahl;        // Wortzahl (optional)
  final int? jahrGelesen;     // Jahr in dem gelesen (optional)
  final String? meta;         // Notizen/Metadaten (optional)
  final double rating;        // Rating 0.0-10.0 (Pflichtfeld)
  final String? coverUrl;     // Pfad zum gespeicherten Cover (optional)
}
```

### Feld-Beschreibungen

| Feld | Typ | Nullable | Beschreibung | Validierung |
|------|-----|----------|--------------|-------------|
| `id` | `int` | ✓ | Datenbank-ID | Auto-Increment |
| `titel` | `String` | ✗ | Buchtitel | Nicht leer |
| `autor` | `String` | ✓ | Autor(en) | - |
| `isbn` | `String` | ✓ | ISBN-10 oder ISBN-13 | Zahlen/Bindestriche |
| `wortzahl` | `int` | ✓ | Anzahl Wörter | > 0 |
| `jahrGelesen` | `int` | ✓ | Jahr gelesen | 1900-2100 |
| `meta` | `String` | ✓ | Notizen/Tags | - |
| `rating` | `double` | ✗ | Rating | 0.0-10.0 |
| `coverUrl` | `String` | ✓ | Lokaler Dateipfad | Absoluter Pfad |

### Konstruktoren

#### Standard-Konstruktor
```dart
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
})
```

#### Factory: fromMap
```dart
factory Book.fromMap(Map<String, dynamic> map)
```

Erstellt ein Book-Objekt aus einer Datenbank-Row.

**Verwendung**:
```dart
final book = Book.fromMap(dbRow);
```

### Methoden

#### toMap()
```dart
Map<String, dynamic> toMap()
```

Konvertiert das Book-Objekt in eine Map für Datenbank-Operationen.

**Rückgabe**: Map mit allen Feldern (außer `id` wenn null)

**Verwendung**:
```dart
await db.insert('books', book.toMap());
```

#### copyWith()
```dart
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
})
```

Erstellt eine Kopie mit geänderten Feldern (immutable update pattern).

**Verwendung**:
```dart
final updatedBook = book.copyWith(rating: 9.5);
```

**Spezialfall**: Felder auf `null` setzen:
```dart
// Autor entfernen
final bookWithoutAuthor = book.copyWith(autor: null);
```

### Datenbank-Mapping

#### SQL-Schema
```sql
CREATE TABLE books (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  titel TEXT NOT NULL,
  autor TEXT,
  isbn TEXT,
  wortzahl INTEGER,
  jahr_gelesen INTEGER,
  meta TEXT,
  rating REAL NOT NULL,
  cover_url TEXT
)
```

#### Field-Mapping
| Dart Field | SQL Column | SQL Type |
|------------|------------|----------|
| `id` | `id` | INTEGER |
| `titel` | `titel` | TEXT |
| `autor` | `autor` | TEXT |
| `isbn` | `isbn` | TEXT |
| `wortzahl` | `wortzahl` | INTEGER |
| `jahrGelesen` | `jahr_gelesen` | INTEGER |
| `meta` | `meta` | TEXT |
| `rating` | `rating` | REAL |
| `coverUrl` | `cover_url` | TEXT |

**Hinweis**: Snake_case in DB, camelCase in Dart

### Verwendungs-Beispiele

#### Neues Buch erstellen
```dart
final newBook = Book(
  titel: 'Der Hobbit',
  autor: 'J.R.R. Tolkien',
  isbn: '978-3-608-93831-4',
  jahrGelesen: 2024,
  rating: 8.5,
);
```

#### Aus Datenbank laden
```dart
final books = await DatabaseService.instance.getAllBooks();
final firstBook = books.first;
```

#### Buch aktualisieren
```dart
final updatedBook = book.copyWith(
  rating: 9.0,
  meta: 'Wirklich großartig!',
);
await DatabaseService.instance.updateBook(updatedBook);
```

#### Buch mit Cover
```dart
final bookWithCover = book.copyWith(
  coverUrl: '/data/user/0/com.bookrater/files/covers/123_9783608938314.jpg',
);
```

## Rating-Werte

### Skala
- **Minimum**: 0.0
- **Maximum**: 10.0
- **Schritte**: 0.01 (zwei Dezimalstellen)

### Tier-Zuordnung
| Rating | Tier | Beschreibung |
|--------|------|--------------|
| 9.0 - 10.0 | S | Meisterwerke |
| 7.5 - 8.99 | A | Exzellent |
| 6.0 - 7.49 | B | Gut |
| 4.0 - 5.99 | C | Okay |
| 2.0 - 3.99 | D | Schwach |
| 0.0 - 1.99 | F | Schlecht |

Siehe `lib/utils/constants.dart` für Details.

### Rating-Algorithmus

Das Rating wird durch Paarvergleiche ermittelt, nicht manuell vergeben.

**Prozess**:
1. Neues Buch wird mit existierenden Büchern verglichen
2. Galloping Search findet die richtige Position
3. PAVA-Algorithmus berechnet finale Ratings
4. Re-Spacing sorgt für konsistente Abstände

Siehe [Rating-System Feature-Dokumentation](../features/rating-system.md).

## ISBN-Format

### Unterstützte Formate
- ISBN-10: `3-608-93831-7`
- ISBN-13: `978-3-608-93831-4`
- Ohne Bindestriche: `9783608938314`

### Validierung
Keine automatische Validierung im Model. Validierung erfolgt bei:
- ISBN-Lookup (ISBN Service)
- Cover-Download (Cover Service)

### Bereinigung
Services bereinigen ISBN automatisch:
```dart
final cleanIsbn = isbn.replaceAll(RegExp(r'[^0-9]'), '');
```

## Cover-URL Format

### Lokale Dateipfade
```
/data/user/0/com.bookrater.book_rater_app/app_flutter/covers/{id}_{isbn}.jpg
```

**Pattern**: `{bookId}_{cleanIsbn}.jpg`

**Beispiel**: `42_9783608938314.jpg`

### Null-Handling
- `coverUrl == null`: Kein Cover vorhanden
- Cover Widget zeigt Placeholder

## Erweiterungen

### Neue Felder hinzufügen

1. **Model erweitern** (`lib/models/book.dart`):
```dart
class Book {
  final String? newField;

  Book({
    // ...
    this.newField,
  });

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      // ...
      newField: map['new_field'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // ...
      'new_field': newField,
    };
  }

  Book copyWith({
    // ...
    String? newField,
  }) {
    return Book(
      // ...
      newField: newField ?? this.newField,
    );
  }
}
```

2. **Datenbank-Migration** (`lib/services/database_service.dart`):
```dart
Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 3) {
    await db.execute('ALTER TABLE books ADD COLUMN new_field TEXT');
  }
}
```

3. **Version erhöhen** (`lib/utils/constants.dart`):
```dart
const int databaseVersion = 3;
```

## Best Practices

### Immutability
✅ **Richtig**: `copyWith()` verwenden
```dart
final updated = book.copyWith(rating: 9.0);
```

❌ **Falsch**: Felder direkt ändern (nicht möglich wegen `final`)

### Null-Safety
✅ **Richtig**: Null-Checks
```dart
if (book.autor != null) {
  print(book.autor!);
}
// Oder:
print(book.autor ?? 'Unbekannt');
```

### Validierung
- Validierung in Screens (UI)
- Zusätzliche Validierung in Services
- Model selbst validiert nicht

---

**Siehe auch**:
- [Database Service](../api/database-service.md)
- [Rating Service](../api/rating-service.md)
- [Projektstruktur](project-structure.md)

**Letzte Aktualisierung**: 2026-07-17
