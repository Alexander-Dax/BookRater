# Changelog

Alle wichtigen Änderungen am BookRater-Projekt werden in dieser Datei dokumentiert.

Das Format basiert auf [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
und dieses Projekt folgt [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Geplant
- Goodreads Import
- Automatische Backups
- Statistik-Dashboard
- Export als PDF


## [1.4.0] - 2026-07-17

### Added (Neu hinzugefügt)
- **Theme Customization**: Auswahl aus 8 vordefinierten Farbschemata
  - Deep Purple (Standard)
  - Ocean Blue
  - Forest Green
  - Sunset Orange
  - Crimson Red
  - Royal Indigo
  - Teak Brown
  - Slate Gray
  - Persistente Speicherung der Theme-Auswahl
  - Material 3 ColorScheme mit automatischer Light/Dark Mode Unterstützung
  - Theme-Auswahl-Screen mit visueller Vorschau
  - Palette-Icon in der Home-Screen AppBar für schnellen Zugriff
  - Sofortige Anwendung des ausgewählten Themes


## [1.3.0] - 2026-07-17

### Added (Neu hinzugefügt)
- **ISBN Lookup Button**: Manueller ISBN-Lookup Button
  - "Laden" Button rechts neben ISBN-Textfeld
  - Verfügbar in Add Book und Edit Book Screens
  - Drei Eingabe-Methoden: Barcode-Scanner, Manuell+Button, Komplett manuell
  - Smart Autofill: Füllt nur leere Felder (überschreibt keine User-Eingaben)
  - Funktioniert auch auf Desktop/Web (ohne Kamera)

- **Import/Export Screen**: Dedizierte Seite für Import/Export-Funktionen
  - CSV Export mit vollständigen Buchdaten
  - CSV Import mit Merge-Funktion
  - Goodreads Import Platzhalter (coming soon)
  - Info-Cards mit Format-Erklärungen

- **ISBN-Scanner Integration**:
  - Barcode-Scanner in Add Book Screen
  - Barcode-Scanner in Edit Book Screen
  - Automatisches ISBN-Lookup via Open Library API
  - Auto-Fill für Titel und Autor
  - Fallback zu Google Books API

- **Vollständige Dokumentation**:
  - Dokumentations-Infrastruktur in `docs/`
  - Architecture Documentation (Projektstruktur, Datenmodelle, ADRs)
  - Feature Documentation (Rating-System)
  - API Documentation (Services)
  - Developer Guides (Setup, Contributing)
  - Code-Style Guidelines

- **Konsistente APK-Signierung**:
  - Fester Keystore für alle Builds
  - Updates ohne Deinstallation möglich
  - Automatisches Laden der Signing-Config
  - Dokumentation in SIGNING_SETUP.md

### Changed (Geändert)
- **Barcode-Scanner Refactoring**:
  - `_scanBarcode()` ruft jetzt `_lookupIsbn()` auf
  - DRY-Prinzip: Lookup-Logik nur an einer Stelle
  - Konsistente Implementierung in beiden Screens

- **Home Screen Refactoring**:
  - CSV Import/Export aus Popup-Menü entfernt
  - Neuer Import/Export Button in AppBar
  - Automatisches Reload nach Import/Export

- **Code Quality Verbesserungen**:
  - Alle `print()` Statements durch Kommentare ersetzt
  - Null-safe Pattern für Map-Returns
  - Optimierte Conditional Assignments
  - 100% `flutter analyze` clean

### Fixed (Behoben)
- **APK Installation**: Updates können jetzt ohne Deinstallation installiert werden
- **ISBN Autofill**: Funktioniert jetzt in beiden Screens (Add & Edit)
- **Linter Issues**: Alle 26 Linter-Warnungen behoben

### Security (Sicherheit)
- Keystore und Credentials in `.gitignore`
- Sichere Aufbewahrung der Signing-Credentials dokumentiert


---

## Version Format

Versions-Nummern folgen Semantic Versioning: `MAJOR.MINOR.PATCH`

- **MAJOR**: Breaking Changes (inkompatible API-Änderungen)
- **MINOR**: Neue Features (rückwärtskompatibel)
- **PATCH**: Bug Fixes (rückwärtskompatibel)

## Kategorien

- **Added**: Neue Features
- **Changed**: Änderungen an bestehenden Features
- **Deprecated**: Features die bald entfernt werden
- **Removed**: Entfernte Features
- **Fixed**: Bug Fixes
- **Security**: Sicherheits-Fixes

## Links

- [Keep a Changelog](https://keepachangelog.com/)
- [Semantic Versioning](https://semver.org/)
- [Project Documentation](docs/README.md)

---

**Hinweis**: Dieses Changelog sollte bei jedem Release aktualisiert werden.
