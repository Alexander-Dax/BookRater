# Architecture Decision Records (ADR)

Dokumentation wichtiger Architektur-Entscheidungen im Projekt.

## Format

Jede Entscheidung wird dokumentiert mit:
- **Status**: Accepted | Superseded | Deprecated
- **Kontext**: Warum war die Entscheidung nötig?
- **Entscheidung**: Was wurde entschieden?
- **Konsequenzen**: Welche Auswirkungen hat die Entscheidung?
- **Alternativen**: Welche Optionen wurden erwogen?

---

## ADR-001: Service-basierte Architektur

**Status**: ✅ Accepted

**Datum**: 2026-07-17

**Kontext**:
Das Projekt benötigt eine klare Trennung zwischen UI und Business Logic. Die App hat verschiedene Datenquellen (Datenbank, APIs, File System) und komplexe Algorithmen.

**Entscheidung**:
Wir verwenden eine Service-basierte Architektur mit klarer Layer-Trennung:
- **Screens** (UI Layer)
- **Services** (Business Logic Layer)
- **Models** (Data Layer)

Alle Services sind Singletons.

**Konsequenzen**:
✅ Klare Verantwortlichkeiten
✅ Einfach testbar (Services können gemockt werden)
✅ Wiederverwendbare Business Logic
✅ Keine DB-Calls in UI-Code
⚠️ Mehr Boilerplate (Service-Klassen)
⚠️ Singleton-Pattern kann Tests erschweren

**Alternativen**:
- **BLoC Pattern**: Zu komplex für dieses Projekt
- **Provider/Riverpod**: Overhead für kleine App
- **GetX**: Vermeidet Magic Strings, aber Overhead

---

## ADR-002: SQLite als Datenbank

**Status**: ✅ Accepted

**Datum**: 2026-07-17

**Kontext**:
Die App benötigt lokale Persistenz für Bücherdaten. Keine Cloud-Synchronisation nötig.

**Entscheidung**:
Wir verwenden SQLite via `sqflite` Package.

**Konsequenzen**:
✅ Bewährte, stabile Technologie
✅ Gute Flutter-Integration
✅ Unterstützt komplexe Queries
✅ Kein Backend nötig
✅ Offline-First
⚠️ Keine automatische Migration
⚠️ Manuelle Schema-Updates nötig

**Alternativen**:
- **Hive**: Schneller, aber weniger flexibel
- **Drift (Moor)**: Typsicher, aber mehr Overhead
- **Shared Preferences**: Zu limitiert für strukturierte Daten
- **Firebase**: Overhead, benötigt Internet

---

## ADR-003: PAVA-Algorithmus für Rating-Spacing

**Status**: ✅ Accepted

**Datum**: 2026-07-17

**Kontext**:
Nach Paarvergleichen müssen Ratings optimal verteilt werden. Einfaches lineares Spacing berücksichtigt nicht die Bauch-Ratings der User.

**Entscheidung**:
Wir implementieren den Pool-Adjacent-Violators Algorithm (PAVA) für isotonische Regression.

**Konsequenzen**:
✅ Respektiert User-Präferenzen (Bauch-Ratings)
✅ Garantiert monoton steigende Ratings
✅ Mathematisch fundiert
✅ Konsistente Ergebnisse
⚠️ Komplexer Algorithmus
⚠️ Schwer zu debuggen

**Alternativen**:
- **Lineares Spacing**: Einfacher, aber ignoriert User-Input
- **Elo-Rating**: Overhead für relative Vergleiche
- **Simpler Durchschnitt**: Inkonsistent bei vielen Vergleichen

---

## ADR-004: Galloping Search für Einsortierung

**Status**: ✅ Accepted

**Datum**: 2026-07-17

**Kontext**:
Neue Bücher müssen effizient in sortierte Liste einsortiert werden. Anzahl der Vergleiche soll minimiert werden.

**Entscheidung**:
Wir verwenden Galloping Search (exponentielle Suche + binäre Suche).

**Konsequenzen**:
✅ O(log n) Komplexität
✅ Weniger Vergleiche als reine binäre Suche
✅ Optimal für sortierte Listen
✅ Gute UX (wenige Vergleiche)
⚠️ Komplexer als einfache binäre Suche

**Alternativen**:
- **Binäre Suche**: Einfacher, aber mehr Vergleiche
- **Lineare Suche**: O(n), zu langsam
- **Random Comparisons**: Schlechte UX

---

## ADR-005: Custom Translation System

**Status**: ✅ Accepted

**Datum**: 2026-07-17

**Kontext**:
App soll mehrsprachig sein. Flutter bietet `intl` Package an.

**Entscheidung**:
Wir implementieren ein einfaches Custom Translation System mit:
- `LanguageService` für State
- `AppTranslations` für String-Maps
- `t(key)` Helper-Methode

**Konsequenzen**:
✅ Einfach zu verstehen
✅ Keine Code-Generation nötig
✅ Schnell neue Strings hinzufügen
✅ Kein Build-Runner overhead
⚠️ Keine Compile-Zeit-Prüfung
⚠️ Typos in Keys möglich
⚠️ Keine Pluralisierung/Interpolation

**Alternativen**:
- **intl Package**: Standard, aber Overhead
- **easy_localization**: Extern abhängig
- **Hardcoded Strings**: Nicht wartbar

---

## ADR-006: StatefulWidget für State Management

**Status**: ✅ Accepted

**Datum**: 2026-07-17

**Kontext**:
App benötigt State Management für UI-Updates.

**Entscheidung**:
Wir verwenden Flutter's eingebaute `StatefulWidget` mit `setState()`.

Für globalen State (Theme, Language): Callbacks und `ChangeNotifier`.

**Konsequenzen**:
✅ Einfach, keine Bibliotheken nötig
✅ Flutter-Standard
✅ Gute für kleine bis mittlere Apps
⚠️ Kann bei großen Apps unübersichtlich werden
⚠️ Prop-Drilling bei tiefen Widget-Trees

**Alternativen**:
- **Provider**: Mehr Features, aber Overhead
- **BLoC**: Zu komplex für dieses Projekt
- **Riverpod**: Modern, aber Lernkurve
- **GetX**: Magisch, vermeidet Explizität

---

## ADR-007: Consistent APK Signing

**Status**: ✅ Accepted

**Datum**: 2026-07-17

**Kontext**:
APK-Updates konnten nicht installiert werden ohne alte App zu löschen, weil jeder Build mit anderem Key signiert wurde.

**Entscheidung**:
Wir erstellen einen festen Keystore und signieren alle Builds (Debug & Release) damit.

**Konsequenzen**:
✅ Updates funktionieren ohne Deinstallation
✅ Datenverlust vermieden
✅ Konsistente User Experience
⚠️ Keystore muss sicher aufbewahrt werden
⚠️ Verlust des Keystores = keine Updates möglich

**Alternativen**:
- **Nur Release signieren**: Debug-Builds unterschiedlich
- **Android Debug Keystore**: Rotiert regelmäßig
- **Play Store Signing**: Nur für Production

Siehe: [../../SIGNING_SETUP.md](../../SIGNING_SETUP.md)

---

## ADR-008: Separate Import/Export Screen

**Status**: ✅ Accepted

**Datum**: 2026-07-17

**Kontext**:
CSV Import/Export war im Popup-Menü versteckt. Zukünftig kommen mehr Import-Optionen (Goodreads).

**Entscheidung**:
Wir erstellen einen dedizierten `ImportExportScreen` mit Sections für verschiedene Quellen.

**Konsequenzen**:
✅ Bessere Auffindbarkeit
✅ Platz für Erklärungen
✅ Erweiterbar für neue Import-Quellen
✅ Klare Struktur
⚠️ Zusätzlicher Screen

**Alternativen**:
- **Popup-Menü**: Platzsparend, aber versteckt
- **Settings-Screen**: Nicht der richtige Ort
- **Dialog**: Zu wenig Platz

---

## ADR-009: ISBN Scanner Integration

**Status**: ✅ Accepted

**Datum**: 2026-07-17

**Kontext**:
ISBN manuell eintippen ist fehleranfällig. ISBN-Scanner sollte auch in Edit-Screen verfügbar sein.

**Entscheidung**:
Wir verwenden `mobile_scanner` Package und integrieren Scanner in Add- und Edit-Screens mit automatischem ISBN-Lookup.

**Konsequenzen**:
✅ Bessere UX (weniger Tippen)
✅ Automatisches Laden von Titel/Autor
✅ Fehlerreduktion
✅ Konsistent in Add & Edit
⚠️ Benötigt Kamera-Permission
⚠️ Funktioniert nicht auf Desktop

**Alternativen**:
- **Nur Add-Screen**: Inkonsistent
- **QR-Code Packages**: mobile_scanner unterstützt beides
- **Manuell**: Schlechte UX

---

## Zukünftige Entscheidungen

Folgende Entscheidungen sollten dokumentiert werden, wenn getroffen:

### ADR-010: Goodreads Import Implementation
- Wie wird Goodreads CSV geparsed?
- Mapping der Felder
- Fehlerbehandlung

### ADR-011: Cloud-Synchronisation
Falls implementiert:
- Backend-Wahl
- Sync-Strategie
- Konfliktauflösung

### ADR-012: Automated Testing
Falls Tests hinzugefügt werden:
- Unit Tests vs Widget Tests vs Integration Tests
- Mocking-Strategie
- CI/CD Integration

---

**Template für neue ADRs**:

```markdown
## ADR-XXX: [Titel]

**Status**: Proposed | Accepted | Superseded | Deprecated

**Datum**: YYYY-MM-DD

**Kontext**:
[Beschreibe das Problem und den Kontext]

**Entscheidung**:
[Was wurde entschieden?]

**Konsequenzen**:
✅ [Vorteile]
⚠️ [Nachteile/Trade-offs]

**Alternativen**:
- **Option 1**: [Beschreibung]
- **Option 2**: [Beschreibung]
```

---

**Letzte Aktualisierung**: 2026-07-17
