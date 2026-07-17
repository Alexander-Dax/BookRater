# Setup & Installation Guide

Anleitung zum Einrichten der Entwicklungsumgebung für BookRater.

## Voraussetzungen

### Software

- **Flutter SDK**: 3.11.5 oder höher
- **Dart SDK**: 3.11.5 oder höher (kommt mit Flutter)
- **Git**: Versionskontrolle
- **IDE**: VS Code oder Android Studio (empfohlen)

### Plattform-spezifisch

#### Android
- Android Studio oder Android SDK
- JDK 17 oder 21 (nicht 25+, siehe [Troubleshooting](#java-version-probleme))
- Android Emulator oder physisches Gerät

#### iOS (optional)
- macOS
- Xcode
- CocoaPods

#### Linux Desktop (optional)
- Linux-Entwicklungstools
- clang, cmake, ninja

## Installation

### 1. Flutter installieren

```bash
# Flutter SDK herunterladen
git clone https://github.com/flutter/flutter.git -b stable
cd flutter

# Flutter zu PATH hinzufügen
export PATH="$PATH:`pwd`/flutter/bin"

# Installation verifizieren
flutter doctor
```

Siehe: https://docs.flutter.dev/get-started/install

### 2. Projekt klonen

```bash
git clone <repository-url>
cd book_rater_app
```

### 3. Dependencies installieren

```bash
flutter pub get
```

Dies installiert alle Packages aus `pubspec.yaml`.

### 4. IDE einrichten

#### VS Code

Installiere Extensions:
- **Flutter** (Dart Code)
- **Dart** (Dart Code)

```bash
code .
```

#### Android Studio

1. Flutter Plugin installieren
2. Dart Plugin installieren
3. Projekt öffnen

### 5. Plattform einrichten

#### Android

```bash
# Android Lizenzen akzeptieren
flutter doctor --android-licenses

# Prüfen
flutter doctor
```

Sollte zeigen:
```
[✓] Android toolchain - develop for Android devices
```

#### iOS (macOS nur)

```bash
# CocoaPods installieren
sudo gem install cocoapods

# iOS Setup
cd ios
pod install
cd ..

# Prüfen
flutter doctor
```

## Projekt starten

### Im Emulator

```bash
# Android Emulator starten
flutter emulators --launch <emulator_id>

# App starten
flutter run
```

### Auf physischem Gerät

#### Android

1. USB-Debugging aktivieren
2. Gerät per USB verbinden
3. ```flutter devices``` - Gerät sollte erscheinen
4. ```flutter run```

#### iOS

1. Developer Account in Xcode einrichten
2. Gerät per USB verbinden
3. ```flutter run```

### Desktop (Linux)

```bash
# Für Linux
flutter run -d linux
```

### Web

```bash
flutter run -d chrome
```

## Entwicklung

### Hot Reload

Während die App läuft:
- **Drücke `r`** im Terminal für Hot Reload
- **Drücke `R`** für Hot Restart
- **Drücke `q`** zum Beenden

### Code-Formatierung

```bash
# Gesamtes Projekt formatieren
flutter format lib/

# Einzelne Datei
flutter format lib/screens/home_screen.dart
```

### Code-Analyse

```bash
# Alle Fehler finden
flutter analyze

# Bestimmte Datei
flutter analyze lib/screens/home_screen.dart
```

## Build erstellen

### Android APK (Debug)

```bash
flutter build apk --debug
```

**Output**: `build/app/outputs/flutter-apk/app-debug.apk`

### Android APK (Release)

```bash
flutter build apk --release
```

**Output**: `build/app/outputs/flutter-apk/app-release.apk`

**Signing**: Siehe [../../SIGNING_SETUP.md](../../../SIGNING_SETUP.md)

### iOS App

```bash
flutter build ios --release
```

### Linux

```bash
flutter build linux --release
```

### Web

```bash
flutter build web --release
```

## APK auf Gerät installieren

### Via ADB

```bash
# Erste Installation
adb install build/app/outputs/flutter-apk/app-release.apk

# Update (ohne Datenverlust)
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

### Via Flutter

```bash
flutter install
```

## Troubleshooting

### Java Version Probleme

**Problem**: Build schlägt fehl mit Java 25.0.3 Fehler

**Lösung**: Java 17 oder 21 verwenden

```bash
# Java Version prüfen
java -version

# Java Version wechseln (Fedora/RHEL)
sudo alternatives --config java

# Flutter Java-Pfad setzen
flutter config --jdk-dir=/usr/lib/jvm/java-17
```

### Flutter Doctor Fehler

```bash
# Detaillierte Ausgabe
flutter doctor -v

# Häufige Fixes
flutter doctor --android-licenses  # Android
flutter pub get                     # Dependencies
flutter clean                       # Build-Cache löschen
```

### Emulator startet nicht

```bash
# Verfügbare Emulatoren anzeigen
flutter emulators

# Emulator erstellen
flutter emulators --create

# Manuell starten (Android Studio)
# Tools → Device Manager → Play
```

### Dependencies-Probleme

```bash
# Cache löschen
flutter pub cache repair

# Dependencies neu installieren
rm -rf .dart_tool/
rm pubspec.lock
flutter pub get
```

### Build-Fehler

```bash
# Alles neu bauen
flutter clean
flutter pub get
flutter build apk
```

### Hot Reload funktioniert nicht

- App neu starten (`R` im Terminal)
- Manchmal sind strukturelle Änderungen nicht Hot-Reload-fähig
- Neustart der IDE

### Linter-Warnungen

```bash
# Alle Warnungen anzeigen
flutter analyze

# Nur Errors
flutter analyze --no-hints --no-warnings
```

## Nützliche Kommandos

```bash
# Flutter Version
flutter --version

# Upgrades prüfen
flutter upgrade

# Gerät-Liste
flutter devices

# Pub Cache leeren
flutter pub cache clean

# Flutter Cache löschen
flutter clean

# Packages aktualisieren
flutter pub upgrade

# Veraltete Packages anzeigen
flutter pub outdated
```

## IDE-Konfiguration

### VS Code Settings

`.vscode/settings.json`:
```json
{
  "dart.lineLength": 80,
  "editor.rulers": [80],
  "editor.formatOnSave": true,
  "[dart]": {
    "editor.formatOnSave": true,
    "editor.selectionHighlight": false
  }
}
```

### Launch Configuration

`.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "book_rater_app",
      "request": "launch",
      "type": "dart"
    }
  ]
}
```

## Umgebungsvariablen

Für sensible Daten (falls benötigt):

```.env
API_KEY=your_api_key
DATABASE_URL=your_database_url
```

In `.gitignore`:
```
.env
```

## Database-Reset

Zum Zurücksetzen der Datenbank während der Entwicklung:

```bash
# Android
adb shell run-as com.bookrater.book_rater_app rm databases/book_rater.db

# Oder: App-Daten löschen
adb shell pm clear com.bookrater.book_rater_app
```

## Next Steps

Nach erfolgreichem Setup:

1. **Code verstehen**: Lies [Projektstruktur](../architecture/project-structure.md)
2. **Feature lernen**: Siehe [Rating-System](../features/rating-system.md)
3. **Beitragen**: Folge [Contributing Guide](../CONTRIBUTING.md)

## Hilfe

- 📖 [Flutter Docs](https://docs.flutter.dev/)
- 🐛 [GitHub Issues](https://github.com/...)
- 💬 Team-Chat

---

**Letzte Aktualisierung**: 2026-07-17
