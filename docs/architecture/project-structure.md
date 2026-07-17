# Projektstruktur

Diese Datei beschreibt die Organisation des BookRater-Projekts.

## 📁 Verzeichnis-Struktur

```
book_rater_app/
├── android/                  # Android-spezifische Konfiguration
│   ├── app/
│   │   ├── src/
│   │   ├── build.gradle.kts  # Android Build-Konfiguration
│   │   └── upload-keystore.jks  # Signing-Keystore (nicht in Git)
│   └── key.properties        # Signing-Credentials (nicht in Git)
│
├── ios/                      # iOS-spezifische Konfiguration
│
├── lib/                      # Haupt-Quellcode
│   ├── main.dart            # App-Einstiegspunkt
│   ├── models/              # Datenmodelle
│   │   └── book.dart        # Book-Modell
│   │
│   ├── screens/             # UI-Screens
│   │   ├── home_screen.dart
│   │   ├── add_book_screen.dart
│   │   ├── edit_book_screen.dart
│   │   ├── comparison_screen.dart
│   │   ├── tierlist_screen.dart
│   │   └── import_export_screen.dart
│   │
│   ├── services/            # Business Logic & Daten-Services
│   │   ├── database_service.dart     # SQLite Datenbank
│   │   ├── rating_service.dart       # PAVA-Algorithmus
│   │   ├── comparison_service.dart   # Galloping Search
│   │   ├── csv_service.dart          # CSV Import/Export
│   │   ├── isbn_service.dart         # ISBN API-Lookup
│   │   ├── cover_service.dart        # Cover-Downloads
│   │   └── language_service.dart     # i18n/Übersetzungen
│   │
│   ├── utils/               # Hilfsfunktionen & Konstanten
│   │   ├── constants.dart   # Tier-Definitionen, DB-Config
│   │   └── translations.dart  # Übersetzungs-Strings
│   │
│   └── widgets/             # Wiederverwendbare UI-Komponenten
│       └── book_cover.dart  # Cover-Widget
│
├── test/                    # Unit- & Widget-Tests
│
├── docs/                    # Projekt-Dokumentation
│   ├── README.md           # Dokumentations-Index
│   ├── architecture/       # Architektur-Docs
│   ├── features/           # Feature-Docs
│   ├── api/               # API-Docs
│   └── guides/            # Entwickler-Guides
│
├── pubspec.yaml            # Flutter Dependencies & Metadaten
├── CHANGELOG.md            # Versions-Historie
└── README.md               # Projekt-Übersicht
```

## 📦 Modul-Organisation

### `/lib/models`
**Zweck**: Datenmodelle und Datenstrukturen

- Immutable Daten-Klassen
- `fromMap()` und `toMap()` für Datenbank-Serialisierung
- `copyWith()` für immutable Updates

**Aktuell**:
- `book.dart` - Book-Modell mit allen Feldern

### `/lib/screens`
**Zweck**: UI-Screens der App

Jeder Screen ist ein `StatefulWidget` mit eigenem State.

**Naming Convention**: `{feature}_screen.dart`

**Aktuell**:
- `home_screen.dart` - Hauptliste aller Bücher
- `add_book_screen.dart` - Neues Buch hinzufügen
- `edit_book_screen.dart` - Buch bearbeiten
- `comparison_screen.dart` - Paarvergleich für Rating
- `tierlist_screen.dart` - S/A/B/C/D/F Visualisierung
- `import_export_screen.dart` - CSV & Goodreads Import/Export

**Verantwortlichkeiten**:
- UI-Rendering
- User-Interaktionen
- Navigation
- Service-Calls
- State-Management (lokal)

### `/lib/services`
**Zweck**: Business Logic & Daten-Operationen

Alle Services sind **Singletons** mit `instance` getter.

**Naming Convention**: `{feature}_service.dart`

**Pattern**:
```dart
class MyService {
  static final MyService instance = MyService._internal();
  MyService._internal();

  // Methods
}
```

**Aktuell**:
- `database_service.dart` - SQLite CRUD
- `rating_service.dart` - Rating-Algorithmen
- `comparison_service.dart` - Sortier-Algorithmen
- `csv_service.dart` - CSV Import/Export
- `isbn_service.dart` - ISBN API-Calls
- `cover_service.dart` - Cover-Downloads
- `language_service.dart` - i18n State

**Verantwortlichkeiten**:
- Datenbank-Zugriff
- API-Calls
- Algorithmen
- File I/O
- Keine UI-Logik!

### `/lib/utils`
**Zweck**: Konstanten, Hilfsfunktionen, Konfiguration

**Aktuell**:
- `constants.dart` - Tier-Definitionen, DB-Konstanten
- `translations.dart` - i18n Strings (DE/EN)

### `/lib/widgets`
**Zweck**: Wiederverwendbare UI-Komponenten

**Naming Convention**: `{component}_widget.dart` oder `{component}.dart`

**Aktuell**:
- `book_cover.dart` - Cover-Display mit Placeholder

**Verantwortlichkeiten**:
- Kleine, fokussierte UI-Komponenten
- Wiederverwendbar über mehrere Screens
- Stateless wo möglich

## 🏗️ Architektur-Patterns

### Service-basierte Architektur

```
┌─────────────┐
│   Screens   │  ← UI Layer
└──────┬──────┘
       │
       ↓
┌─────────────┐
│  Services   │  ← Business Logic Layer
└──────┬──────┘
       │
       ↓
┌─────────────┐
│   Models    │  ← Data Layer
└─────────────┘
```

**Regeln**:
1. Screens rufen Services auf (nie direkt DB)
2. Services arbeiten mit Models
3. Models sind dumme Datencontainer
4. Services sind Singletons
5. Keine Business-Logic in Screens

### State Management

**Lokaler State**: `StatefulWidget` mit `setState()`
- Für UI-State (z.B. Loading-Indikatoren)
- Für Form-Inputs

**Globaler State**: `ChangeNotifier` (nur für LanguageService)
- Für App-weite Settings
- Theme-Wechsel via Callback

### Datenfluss

```
User Action (Screen)
      ↓
Service Method Call
      ↓
Database/API Operation
      ↓
Return Data/Result
      ↓
setState() in Screen
      ↓
UI Update
```

## 📱 Screen-Navigation

**Pattern**: `Navigator.push()` mit `MaterialPageRoute`

**Beispiel**:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => EditBookScreen(book: book),
  ),
);
```

**Return-Values**: Screens können Ergebnisse zurückgeben:
```dart
final result = await Navigator.push(...);
if (result != null) {
  // Handle result
}
```

## 🗄️ Datenbank-Schema

Siehe [data-models.md](data-models.md) für Details.

**Tabellen**:
- `books` - Alle Buch-Daten

**Engine**: SQLite via `sqflite` Package

## 🌍 Internationalisierung

**Sprachen**: Deutsch (DE), English (EN)

**System**: Custom Translation Service
- `LanguageService` für State
- `AppTranslations` für Strings
- `t(key)` Helper in Screens

Siehe [../guides/i18n.md](../guides/i18n.md) für Details.

## 🔑 Naming Conventions

### Dateien
- **Screens**: `{feature}_screen.dart`
- **Services**: `{feature}_service.dart`
- **Models**: `{entity}.dart`
- **Widgets**: `{component}.dart`

### Klassen
- **Screens**: `{Feature}Screen extends StatefulWidget`
- **Services**: `{Feature}Service` (Singleton)
- **Models**: `{Entity}` (z.B. `Book`)

### Variablen
- **Private**: `_variableName`
- **Public**: `variableName`
- **Constants**: `constantName` oder `CONSTANT_NAME`

### Methoden
- **Private**: `_methodName()`
- **Public**: `methodName()`
- **Async**: `methodName()` (kein `async` im Namen)

## 📊 Dependencies

Siehe `pubspec.yaml` für vollständige Liste.

**Wichtigste**:
- `sqflite` - SQLite Datenbank
- `path_provider` - File-System-Zugriff
- `mobile_scanner` - Barcode-Scanner
- `http` - HTTP-Requests
- `file_picker` - Datei-Auswahl

## 🚀 Build-Outputs

```
build/
├── app/
│   └── outputs/
│       └── flutter-apk/
│           ├── app-debug.apk
│           └── app-release.apk
```

## 📝 Weitere Dokumentation

- [Datenmodelle](data-models.md)
- [Architektur-Entscheidungen](decisions.md)
- [Service-Dokumentation](../api/)
- [Feature-Dokumentation](../features/)

---

**Letzte Aktualisierung**: 2026-07-17
