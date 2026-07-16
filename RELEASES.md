# Release Anleitung

Diese Datei erklärt, wie du neue Releases baust und auf GitHub veröffentlichst.

## Automatische Builds

Die GitHub Actions Pipeline baut automatisch APKs in folgenden Szenarien:

### 1. Latest Build (bei jedem Push)

**Was passiert:**
Jeder Push auf `main` oder `master` erstellt automatisch ein "Latest" Pre-Release mit der neuesten APK.

**Wie pushen:**
```bash
# Normale Änderungen committen und pushen
git add .
git commit -m "Deine Änderung beschreibung"
git push origin main
```

**Wo finden:**
- GitHub Repository → Releases
- Suche nach dem Release mit Tag `latest`
- Download: `app-release.apk`

**Achtung:**
- Dies ist ein Pre-Release (als "instabil" markiert)
- Wird bei jedem Push überschrieben
- Gut zum Testen, aber nicht für Produktiv-Versionen

### 2. Stable Release (mit Version-Tag)

**Was passiert:**
Ein offizielles, stabiles Release mit Versionsnummer wird erstellt.

**Wie pushen:**
```bash
# 1. Version in pubspec.yaml anpassen (optional, aber empfohlen)
cd book_rater_app
# Editiere pubspec.yaml: version: 1.2.0+3

# 2. Änderungen committen
git add .
git commit -m "Release v1.2.0: Beschreibung der neuen Features"

# 3. Tag erstellen und pushen
git tag v1.2.0
git push origin main
git push origin v1.2.0
```

**Wo finden:**
- GitHub Repository → Releases
- Suche nach dem Release mit deinem Tag (z.B. `v1.2.0`)
- Download: `app-release.apk`

**Vorteile:**
- Stabile, nummerierte Version
- Automatische Release Notes
- Bleibt dauerhaft verfügbar (wird nicht überschrieben)

### 3. Manueller Build

**Was passiert:**
Du kannst die Pipeline auch manuell auslösen ohne zu pushen.

**Wie starten:**
1. Gehe zu GitHub Repository → Actions
2. Wähle "Build and Release APK" Workflow
3. Klicke "Run workflow"
4. Wähle Branch (main/master)
5. Klicke "Run workflow"

**Wo finden:**
- GitHub Repository → Actions → Dein Workflow Run
- Scrolle runter zu "Artifacts"
- Download: `book-rater-apk.zip`

**Hinweis:**
- Artifacts bleiben nur 30 Tage verfügbar
- Kein Release wird erstellt, nur Artifact zum Download

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
| Schnelles Testen | `git push origin main` | Latest Pre-Release |
| Stable Release | `git tag v1.0.0 && git push --tags` | Offizielles Release v1.0.0 |
| Nur Build, kein Release | GitHub Actions → Run workflow | Artifact (30 Tage) |

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

### Latest Release fehlt

- Dauert ~5-10 Minuten nach Push
- Prüfe Actions Tab ob Workflow läuft
- Bei Fehler: Siehe "Build schlägt fehl"

### Tag-Release funktioniert nicht

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

## Lokaler Build (ohne GitHub)

Falls du die APK lokal bauen willst:

```bash
cd book_rater_app
flutter build apk --release

# APK finden unter:
# build/app/outputs/flutter-apk/app-release.apk
```
