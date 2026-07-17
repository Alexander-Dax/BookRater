# Contributing Guide

Danke für dein Interesse am BookRater-Projekt! Dieses Dokument beschreibt, wie du beitragen kannst.

## 🚀 Quick Start

```bash
# 1. Repository forken und klonen
git clone https://github.com/your-username/book_rater_app.git
cd book_rater_app

# 2. Dependencies installieren
flutter pub get

# 3. App starten
flutter run

# 4. Änderungen machen
# 5. Tests ausführen
flutter analyze
flutter test

# 6. Pull Request erstellen
```

## 📋 Contribution-Prozess

### 1. Issue erstellen (optional)

Für größere Features oder Bug Fixes:
1. Prüfe ob bereits ein Issue existiert
2. Erstelle ein neues Issue mit Beschreibung
3. Warte auf Feedback bevor du anfängst

Für kleine Fixes: Direkt Pull Request erstellen

### 2. Branch erstellen

```bash
git checkout -b feature/mein-feature
# oder
git checkout -b fix/mein-bugfix
```

**Naming**:
- `feature/` für neue Features
- `fix/` für Bug Fixes
- `docs/` für Dokumentation
- `refactor/` für Refactorings

### 3. Änderungen machen

- Folge dem [Code Style](#code-style)
- Schreibe klaren, lesbaren Code
- Kommentiere komplexe Logik
- Aktualisiere die Dokumentation

### 4. Testen

```bash
# Code-Analyse
flutter analyze

# Formatierung prüfen
flutter format --set-exit-if-changed lib/

# Tests (wenn vorhanden)
flutter test
```

### 5. Commit erstellen

```bash
git add .
git commit -m "feat: Beschreibung der Änderung"
```

**Commit Message Format**:
```
<typ>: <beschreibung>

[optionaler body]
```

**Typen**:
- `feat:` Neues Feature
- `fix:` Bug Fix
- `docs:` Dokumentation
- `style:` Formatierung, Semicolons, etc.
- `refactor:` Code-Umstrukturierung
- `test:` Tests hinzufügen/ändern
- `chore:` Build-Prozess, Dependencies, etc.

**Beispiele**:
```
feat: Add Goodreads import feature
fix: Fix ISBN scanner crash on Android
docs: Update rating system documentation
refactor: Extract comparison logic to service
```

### 6. Push und Pull Request

```bash
git push origin feature/mein-feature
```

Erstelle dann einen Pull Request auf GitHub mit:
- **Titel**: Kurze Beschreibung
- **Beschreibung**: Was wurde geändert und warum?
- **Screenshots**: Für UI-Änderungen
- **Testing**: Wie wurde getestet?

## 💻 Code Style

### Dart/Flutter Standards

Wir folgen den offiziellen Dart Style Guidelines:
- https://dart.dev/guides/language/effective-dart/style

**Wichtigste Regeln**:

#### Naming
```dart
// Classes: PascalCase
class BookService {}

// Files: snake_case
// book_service.dart

// Variables/Methods: camelCase
final bookTitle = '...';
void fetchBooks() {}

// Constants: camelCase
const double minGap = 0.05;

// Private: _prefix
String _privateMethod() {}
```

#### Formatting
```bash
# Auto-Format
flutter format lib/
```

- 2 Spaces Indentation
- Max 80 Zeichen pro Zeile (120 für lange Strings ok)
- Trailing Commas für besseres Git-Diff

#### Kommentare
```dart
/// Public API: Doc-Comments mit ///
///
/// Beschreibt was die Methode tut.
void publicMethod() {}

// Private: Regular Comments mit //
// Erklärt Implementierungs-Details
void _privateMethod() {}
```

### Projekt-spezifische Konventionen

#### Services
```dart
/// Service für [Feature]
class FeatureService {
  // Singleton Pattern
  static final FeatureService instance = FeatureService._internal();
  FeatureService._internal();

  // Public API
  /// Beschreibung
  Future<Result> doSomething() async {
    // Implementation
  }

  // Private helpers
  void _privateHelper() {
    // Implementation
  }
}
```

#### Screens
```dart
/// Screen für [Feature]
class FeatureScreen extends StatefulWidget {
  final RequiredParam param;

  const FeatureScreen({super.key, required this.param});

  @override
  State<FeatureScreen> createState() => _FeatureScreenState();
}

class _FeatureScreenState extends State<FeatureScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // UI
    );
  }
}
```

#### Imports
```dart
// Dart-Bibliotheken zuerst
import 'dart:async';
import 'dart:io';

// Flutter-Packages
import 'package:flutter/material.dart';

// Externe Packages
import 'package:sqflite/sqflite.dart';

// Lokale Imports (relativ)
import '../models/book.dart';
import '../services/database_service.dart';
```

## 📖 Dokumentation

### Wann dokumentieren?

- ✅ Neue Features
- ✅ API-Änderungen
- ✅ Architektur-Entscheidungen
- ✅ Komplexe Algorithmen
- ✅ Neue Dependencies

### Wo dokumentieren?

- **Code**: Doc-Comments (`///`) für Public APIs
- **Features**: `docs/features/{feature}.md`
- **API**: `docs/api/{service}.md`
- **Architecture**: `docs/architecture/decisions.md`
- **Guides**: `docs/guides/{topic}.md`

### Template

Siehe `docs/templates/` für Templates.

## 🧪 Testing

### Aktueller Stand

Momentan gibt es noch keine automatischen Tests.

### Manuelle Tests

Vor jedem Pull Request:

1. **Feature testen**:
   - Neue Funktionalität ausprobieren
   - Edge Cases prüfen
   - Verschiedene Szenarien

2. **Regression testen**:
   - Bestehende Features noch funktionsfähig?
   - Keine neuen Crashes?

3. **UI testen**:
   - Verschiedene Screen-Größen
   - Dark/Light Theme
   - Deutsch/English

### Zukünftige Tests

Wenn Tests hinzugefügt werden:

```dart
// test/services/rating_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:book_rater_app/services/rating_service.dart';

void main() {
  group('RatingService', () {
    test('PAVA maintains monotonicity', () {
      final input = [1.0, 3.0, 2.0, 4.0];
      final result = RatingService.respace(input);

      for (int i = 1; i < result.length; i++) {
        expect(result[i], greaterThanOrEqualTo(result[i-1]));
      }
    });
  });
}
```

## 🎨 UI/UX Guidelines

### Material Design 3

Wir folgen Material Design 3 Guidelines:
- https://m3.material.io/

### Farben

Nutze Theme-Colors statt hardcoded Colors:
```dart
// ✅ Richtig
color: Theme.of(context).colorScheme.primary

// ❌ Falsch
color: Colors.blue
```

### Spacing

Konsistente Abstände:
```dart
const EdgeInsets.all(16)    // Standard-Padding
const EdgeInsets.all(8)     // Klein
const EdgeInsets.all(24)    // Groß

const SizedBox(height: 16)  // Standard-Abstand
const SizedBox(height: 8)   // Klein
const SizedBox(height: 24)  // Groß
```

### Icons

Nutze Material Icons:
```dart
Icon(Icons.book)
Icon(Icons.add)
Icon(Icons.edit)
```

## 🌍 Internationalisierung (i18n)

### Neue Strings hinzufügen

1. **In `lib/utils/translations.dart`**:
```dart
'de': {
  'my_new_key': 'Deutscher Text',
},
'en': {
  'my_new_key': 'English Text',
},
```

2. **Im Code verwenden**:
```dart
Text(t('my_new_key'))
```

### Richtlinien

- Keys: `snake_case`
- Werte: Kurz und prägnant
- Konsistente Terminologie
- Beide Sprachen gleichzeitig pflegen

## 🔐 Sicherheit

### Sensible Daten

- ❌ NIEMALS Passwörter, API-Keys, etc. committen
- ❌ NIEMALS Keystore-Dateien committen
- ✅ `.gitignore` prüfen
- ✅ Environment Variables für Secrets

### Dependencies

- Nur vertrauenswürdige Packages
- Regelmäßig auf Updates prüfen
- Security Advisories beachten

## 📝 Checklist

Vor dem Pull Request:

- [ ] Code folgt dem Style Guide
- [ ] `flutter analyze` läuft ohne Fehler
- [ ] `flutter format` angewendet
- [ ] Dokumentation aktualisiert
- [ ] Manuell getestet
- [ ] Keine Debug-Prints im Code
- [ ] Keine TODO-Kommentare (oder als Issue angelegt)
- [ ] Keine sensiblen Daten committed

## ❓ Fragen?

- 📖 Lies die [Dokumentation](README.md)
- 🐛 Erstelle ein [Issue](https://github.com/...)
- 💬 Frage im Team-Chat

## 📚 Hilfreiche Links

- [Flutter Docs](https://docs.flutter.dev/)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Material Design 3](https://m3.material.io/)
- [Projekt-Architektur](architecture/project-structure.md)
- [Rating-System](features/rating-system.md)

---

**Vielen Dank für deinen Beitrag! 🎉**
