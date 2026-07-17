# BookRater Documentation

Willkommen zur technischen Dokumentation des BookRater-Projekts!

## 📚 Dokumentations-Übersicht

Diese Dokumentation ist in verschiedene Bereiche aufgeteilt, um eine einfache Navigation und Wartung zu ermöglichen.

### Für Entwickler

- **[Architektur](architecture/)** - System-Design, Datenmodelle, Architektur-Patterns
  - [Projektstruktur](architecture/project-structure.md)
  - [Datenmodelle](architecture/data-models.md)
  - [Architektur-Entscheidungen](architecture/decisions.md)

- **[Features](features/)** - Detaillierte Feature-Dokumentation
  - [Buch-Management](features/book-management.md)
  - [Rating-System](features/rating-system.md)
  - [ISBN-Scanner](features/isbn-scanner.md)
  - [Import/Export](features/import-export.md)
  - [Tier-List](features/tier-list.md)

- **[API & Services](api/)** - Service-Schicht Dokumentation
  - [Database Service](api/database-service.md)
  - [Rating Service](api/rating-service.md)
  - [Comparison Service](api/comparison-service.md)
  - [CSV Service](api/csv-service.md)
  - [ISBN Service](api/isbn-service.md)
  - [Cover Service](api/cover-service.md)

- **[Guides](guides/)** - Entwicklungs-Anleitungen
  - [Setup & Installation](guides/setup.md)
  - [Neue Features hinzufügen](guides/adding-features.md)
  - [Testing](guides/testing.md)
  - [Deployment](guides/deployment.md)
  - [Internationalisierung](guides/i18n.md)

### Für Contributors

- **[Contributing](CONTRIBUTING.md)** - Wie man zum Projekt beiträgt
- **[Code Style](guides/code-style.md)** - Coding-Standards und Best Practices
- **[Git Workflow](guides/git-workflow.md)** - Branching-Strategie und Commit-Conventions

## 🚀 Quick Start

### Entwicklungsumgebung einrichten
```bash
# Repository klonen
git clone <repository-url>
cd book_rater_app

# Dependencies installieren
flutter pub get

# App starten
flutter run
```

Mehr Details: [Setup Guide](guides/setup.md)

### Erste Schritte

1. Lies die [Projektstruktur](architecture/project-structure.md)
2. Verstehe das [Rating-System](features/rating-system.md)
3. Schau dir die [API-Dokumentation](api/) an
4. Folge dem [Contributing Guide](CONTRIBUTING.md)

## 📖 Dokumentations-Standards

### Wann aktualisieren?

Die Dokumentation sollte aktualisiert werden, wenn:

- ✅ Neue Features hinzugefügt werden
- ✅ Bestehende Features geändert werden
- ✅ Architektur-Entscheidungen getroffen werden
- ✅ APIs sich ändern
- ✅ Neue Services erstellt werden
- ✅ Dependencies aktualisiert werden

### Wie aktualisieren?

1. **Während der Entwicklung**: Dokumentation parallel zum Code schreiben
2. **Pull Requests**: Dokumentation als Teil des PR einreichen
3. **Reviews**: Dokumentation als Teil des Code-Reviews prüfen

### Format-Richtlinien

- Verwende Markdown (`.md`)
- Klare, prägnante Sprache
- Code-Beispiele mit Syntax-Highlighting
- Screenshots/Diagramme wo hilfreich
- Inhaltsverzeichnis bei längeren Dokumenten
- Versionierung bei API-Changes

## 🔍 Suche & Navigation

### Nach Thema suchen

- **Datenbank**: [Database Service](api/database-service.md)
- **Ratings berechnen**: [Rating Service](api/rating-service.md)
- **Bücher vergleichen**: [Comparison Service](api/comparison-service.md)
- **ISBN scannen**: [ISBN-Scanner Feature](features/isbn-scanner.md)
- **CSV Import/Export**: [Import/Export Feature](features/import-export.md)
- **Übersetzungen**: [i18n Guide](guides/i18n.md)

### Nach Datei/Klasse suchen

Nutze die [API-Dokumentation](api/) für spezifische Klassen und Methoden.

## 📝 Template-Dateien

Für neue Dokumentation gibt es Templates in `docs/templates/`:
- Feature-Dokumentation Template
- API-Dokumentation Template
- Architecture Decision Record (ADR) Template

## 🤝 Hilfe & Support

### Fragen?

1. Durchsuche die Dokumentation
2. Prüfe die [FAQ](guides/faq.md)
3. Erstelle ein Issue auf GitHub
4. Frage im Team-Chat

### Dokumentation verbessern?

Fehler gefunden? Verbesserungsvorschlag? Siehe [Contributing Guide](CONTRIBUTING.md)!

## 📌 Wichtige Links

- **Haupt-README**: [../README.md](../README.md)
- **Changelog**: [../CHANGELOG.md](../CHANGELOG.md)
- **Signing Setup**: [../../SIGNING_SETUP.md](../../SIGNING_SETUP.md)
- **Quick Reference**: [../../QUICK_REFERENCE.md](../../QUICK_REFERENCE.md)

## 📊 Projekt-Statistik

- **Sprache**: Dart (Flutter)
- **Plattformen**: Android, iOS, Linux, Web
- **Datenbank**: SQLite (sqflite)
- **State Management**: StatefulWidget + ChangeNotifier
- **Architektur**: Service-basiert mit klarer Trennung

---

**Letzte Aktualisierung**: 2026-07-17
**Version**: 1.3.0
**Maintainer**: BookRater Team
