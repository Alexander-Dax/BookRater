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

## 📚 Dokumentation

Die vollständige technische Dokumentation findest du unter **[docs/](docs/)**:

- **[Dokumentations-Index](docs/README.md)** - Übersicht über alle Docs
- **[Setup Guide](docs/guides/setup.md)** - Installation & Entwicklungsumgebung
- **[Contributing Guide](docs/CONTRIBUTING.md)** - Wie man beiträgt
- **[Projektstruktur](docs/architecture/project-structure.md)** - Code-Organisation
- **[Rating-System](docs/features/rating-system.md)** - Algorithmen erklärt
- **[API-Docs](docs/api/)** - Service-Dokumentation

### Quick Links

- **Signing Setup**: [../SIGNING_SETUP.md](../SIGNING_SETUP.md) - APK-Signierung konfigurieren
- **Quick Reference**: [../QUICK_REFERENCE.md](../QUICK_REFERENCE.md) - Häufige Befehle
- **Changelog**: [CHANGELOG.md](CHANGELOG.md) - Versions-Historie

## Entwicklung

### Voraussetzungen
```bash
flutter --version  # 3.11.5 oder höher
dart --version     # 3.11.5 oder höher
```

### Quick Start
```bash
# 1. Dependencies installieren
flutter pub get

# 2. App starten
flutter run

# 3. Build erstellen
flutter build apk --release
```

Detaillierte Anleitung: [Setup Guide](docs/guides/setup.md)

### Projektstruktur
```
book_rater_app/
├── lib/
│   ├── main.dart              # App Entry Point
│   ├── models/                # Datenmodelle
│   ├── services/              # Business Logic
│   ├── screens/               # UI Screens
│   ├── widgets/               # Wiederverwendbare Widgets
│   └── utils/                 # Konstanten, Helpers
├── docs/                      # 📚 Vollständige Dokumentation
│   ├── architecture/          # System-Design
│   ├── features/              # Feature-Beschreibungen
│   ├── api/                   # API-Dokumentation
│   └── guides/                # Entwickler-Guides
└── android/                   # Android-Konfiguration
```

Mehr Details: [Projektstruktur-Dokumentation](docs/architecture/project-structure.md)

## Migration von Python

Diese App ist eine komplette Neuimplementierung des ursprünglichen Python-Systems (`book_ranker.py`). Die Kernalgorithmen (PAVA, Galloping Search) wurden von Python nach Dart übersetzt.

## Lizenz

Privates Projekt

## Autor

Alex
