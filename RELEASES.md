# Release Anleitung

Diese Datei erklärt, wie du neue Releases baust und auf GitHub veröffentlichst.

## Automatische Builds

Die GitHub Actions Pipeline baut automatisch APKs nur bei Version-Tags:

### Release mit Version-Tag

**Was passiert:**
Ein offizielles, stabiles Release mit Versionsnummer wird erstellt.

**Wie pushen:**
```bash
# 1. Version in pubspec.yaml anpassen (empfohlen)
# Editiere pubspec.yaml: version: 1.2.0+3

# 2. Änderungen committen
git add .
git commit -m "Release v1.2.0: Beschreibung der neuen Features"
git push origin main

# 3. Tag erstellen und pushen (triggert den Build!)
git tag v1.2.0
git push origin v1.2.0
```

**Wo finden:**
- GitHub Repository → Releases
- Suche nach dem Release mit deinem Tag (z.B. `v1.2.0`)
- Download: `app-release.apk`

**Wichtig:**
- Nur Tags mit Format `v*` (z.B. v1.0.0, v2.1.3) triggern den Build
- Normale Commits ohne Tag bauen KEINE APK
- APK wird automatisch als Release mit Release Notes bereitgestellt

## Versionsnummern

### Empfohlenes Schema (Semantic Versioning)

```
version: MAJOR.MINOR.PATCH+BUILD

Beispiel: 1.2.3+5
```

- **MAJOR** (1.x.x): Breaking Changes, große Umbauten
- **MINOR** (x.2.x): Neue Features, rückwärtskompatibel
- **PATCH** (x.x.3): Bugfixes
- **BUILD** (+5): Build-Nummer (automatisch erhöhen)

### Wo eintragen:

Datei: `book_rater_app/pubspec.yaml`
```yaml
name: book_rater_app
description: "Book Rating App mit Tier-List"
version: 1.2.3+5  # <-- HIER
```

### Wann erhöhen:

- **Bugfix**: `1.0.0` → `1.0.1`
- **Neues Feature**: `1.0.1` → `1.1.0`
- **Breaking Change**: `1.1.0` → `2.0.0`
- **Jeder Build**: `1.0.0+5` → `1.0.0+6`

## Quick Reference

| Szenario | Befehle | Resultat |
|----------|---------|----------|
| Normaler Commit | `git push origin main` | Kein Build |
| Release erstellen | `git tag v1.0.0 && git push origin v1.0.0` | APK Build + Release v1.0.0 |
| Manueller Build | GitHub Actions → Run workflow | Artifact (30 Tage) |

## Troubleshooting

### Build schlägt fehl

1. Prüfe GitHub Actions Log:
   - Repository → Actions → Fehlgeschlagener Workflow
   - Klicke auf "Build APK" Job
   - Lies Fehlermeldetungen

2. Häufige Probleme:
   - **Dependency errors**: `flutter pub get` lokal testen
   - **Build errors**: `flutter build apk` lokal testen
   - **Java version**: Workflow nutzt Java 17

### Release wird nicht erstellt

- Build wird nur bei Tags mit Format `v*` getriggert (z.B. v1.0.0)
- Dauert ~5-10 Minuten nach Tag-Push
- Prüfe Actions Tab ob Workflow läuft
- Bei Fehler: Siehe "Build schlägt fehl"

### Tag funktioniert nicht

```bash
# Tag prüfen
git tag

# Tag löschen (falls falsch)
git tag -d v1.0.0
git push origin :refs/tags/v1.0.0

# Neu erstellen
git tag v1.0.0
git push origin v1.0.0
```

## Workflow-Datei

Die komplette Pipeline-Konfiguration findest du hier:
`.github/workflows/build-apk.yml`

Bei Problemen oder Anpassungswünschen kannst du diese Datei editieren.

## Manueller Build

### Über GitHub Actions (ohne Tag)

1. Gehe zu GitHub Repository → Actions
2. Wähle "Build and Release APK" Workflow
3. Klicke "Run workflow"
4. Klicke "Run workflow"

**Ergebnis:**
- Workflow läuft und baut APK
- APK verfügbar unter Actions → Workflow Run → Artifacts (30 Tage)
- KEIN Release wird erstellt

### Lokal auf deinem Rechner

```bash
flutter build apk --release

# APK finden unter:
# build/app/outputs/flutter-apk/app-release.apk
```
