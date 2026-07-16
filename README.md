# BookRater

Eine Android-App zum Bewerten und Sortieren von Büchern mit visueller Tier-List Darstellung.

## Features

### Kernfunktionen
- **Paarweise Vergleiche**: Bücher werden durch direkte Vergleiche sortiert (besser/gleich/schlechter)
- **PAVA-Algorithmus**: Automatische Neuberechnung der Ratings für konsistente Abstände
- **Galloping Search**: Effizienter Algorithmus zum Einsortieren neuer Bücher
- **Tier-List Visualisierung**: S/A/B/C/D/F Kategorisierung mit farblicher Darstellung

### Verwaltung
- **Bücher hinzufügen**: Titel, Autor, ISBN, Wortzahl, Jahr, Meta-Informationen
- **Bücher bearbeiten**: Ändern von Informationen und Neu-Einsortieren bei Rating-Änderungen
- **Bücher löschen**: Mit Bestätigungsdialog
- **ISBN-Unterstützung**: Automatischer Download von Buchcovern über Open Library API

### Darstellung
- **Dark Mode**: Umschaltbar zwischen hellem und dunklem Theme
- **Cover-Anzeige**: Automatischer Download und Anzeige von Buchcovern
- **Statistiken**: Übersicht über Buchanzahl und durchschnittliches Rating

## Download

Die neueste APK kann unter [Releases](../../releases) heruntergeladen werden:
- **Latest**: Automatisch gebaut bei jedem Push (kann instabil sein)
- **Stable Releases**: Offizielle Versionen mit Tag (v1.0.0, etc.)

## Installation

1. APK von den Releases herunterladen
2. Auf Android-Gerät übertragen
3. "Installation aus unbekannten Quellen" erlauben
4. APK installieren

## Technische Details

### Technologie-Stack
- **Framework**: Flutter 3.24+ mit Dart
- **Datenbank**: SQLite (sqflite)
- **Plattformen**: Android (primär), Linux Desktop (zum Testen)

### Algorithmen
- **PAVA** (Pool-Adjacent-Violators): Isotonische Regression für konsistente Rating-Abstände
- **Galloping Search**: Binäre Suche mit exponentieller Intervallvergrößerung
- **Cover Download**: Open Library Cover API

### Datenbankstruktur
```sql
CREATE TABLE books (
  id INTEGER PRIMARY KEY,
  titel TEXT NOT NULL,
  autor TEXT,
  isbn TEXT,
  wortzahl INTEGER,
  jahr_gelesen INTEGER,
  meta TEXT,
  rating REAL NOT NULL,
  cover_url TEXT
);
```

### Tier-Kategorien
| Tier | Rating-Bereich | Farbe | Bedeutung |
|------|----------------|-------|-----------|
| S    | 9.5 - 10.0     | Gold  | Außergewöhnlich |
| A    | 8.5 - 9.5      | Grün  | Exzellent |
| B    | 7.0 - 8.5      | Blau  | Sehr gut |
| C    | 5.0 - 7.0      | Orange| Gut |
| D    | 3.0 - 5.0      | Rot   | Mittelmäßig |
| F    | 0.0 - 3.0      | Grau  | Schwach |

## Entwicklung

### Voraussetzungen
```bash
flutter --version  # 3.24.0 oder höher
dart --version     # 3.5.0 oder höher
```

### Setup
```bash
cd book_rater_app
flutter pub get
flutter run -d linux  # Zum Testen auf Linux
flutter build apk --release  # Android APK bauen
```

### Projektstruktur
```
book_rater_app/
├── lib/
│   ├── main.dart              # App Entry Point
│   ├── models/
│   │   └── book.dart          # Book Datenmodell
│   ├── services/
│   │   ├── database_service.dart     # SQLite CRUD
│   │   ├── rating_service.dart       # PAVA Algorithmus
│   │   ├── comparison_service.dart   # Galloping Search
│   │   └── cover_service.dart        # Cover Downloads
│   ├── screens/
│   │   ├── home_screen.dart          # Hauptansicht (Liste)
│   │   ├── add_book_screen.dart      # Buch hinzufügen
│   │   ├── edit_book_screen.dart     # Buch bearbeiten
│   │   ├── comparison_screen.dart    # Vergleichs-UI
│   │   └── tierlist_screen.dart      # Tier-List Ansicht
│   ├── widgets/
│   │   └── book_cover.dart           # Wiederverwendbare Cover-Anzeige
│   └── utils/
│       └── constants.dart            # Tier-Definitionen, Konstanten
└── android/
    └── app/src/main/AndroidManifest.xml  # App-Berechtigungen
```

## Migration von Python

Diese App ist eine komplette Neuimplementierung des ursprünglichen Python-Systems (`book_ranker.py`). Die Kernalgorithmen (PAVA, Galloping Search) wurden von Python nach Dart übersetzt.

## Lizenz

Privates Projekt

## Autor

Alex
