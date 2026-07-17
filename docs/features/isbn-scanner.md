# ISBN-Scanner & Autofill

Das ISBN-Feature ermöglicht schnelles Erfassen von Buchdaten durch automatische Metadaten-Abfrage.

## Übersicht

Anstatt Titel, Autor und Cover manuell einzugeben, können Buchdaten automatisch via ISBN geladen werden.

**Verfügbar in**:
- ✅ Add Book Screen
- ✅ Edit Book Screen

## Drei Eingabe-Methoden

### 1. 📷 Barcode-Scanner (Kamera)

**Verwendung**:
1. Klicke auf das Scanner-Icon (📷) im ISBN-Feld
2. Halte Kamera über ISBN-Barcode
3. Barcode wird automatisch erkannt
4. ISBN wird ins Feld eingetragen
5. Automatischer Lookup startet
6. Felder werden gefüllt

**Vorteile**:
- ✅ Schnellste Methode
- ✅ Keine Tipp-Fehler
- ✅ Funktioniert mit allen Standard-Barcodes

**Nachteile**:
- ⚠️ Benötigt Kamera-Permission
- ⚠️ Nur auf Mobilgeräten verfügbar

### 2. 🔍 Manuell + Laden-Button (NEU)

**Verwendung**:
1. Tippe ISBN manuell ins Feld
2. Klicke "Laden" Button rechts neben dem Feld
3. Daten werden automatisch geladen
4. Felder werden gefüllt

**Vorteile**:
- ✅ Funktioniert überall (auch Desktop/Web)
- ✅ Gut wenn Barcode unleserlich/nicht vorhanden
- ✅ Flexible Korrektur möglich

**Use Cases**:
- ISBN aus E-Mail/Website kopiert
- Barcode beschädigt/unleserlich
- Desktop-Entwicklung
- ISBN von anderer Quelle

### 3. ✏️ Komplett Manuell

**Verwendung**:
1. Alle Felder selbst ausfüllen
2. Kein Lookup nötig

**Vorteile**:
- ✅ Volle Kontrolle
- ✅ Funktioniert ohne Internet
- ✅ Für Bücher ohne ISBN

## UI-Layout

```
┌─────────────────────────────────────┬────────────┐
│ ISBN                               │  [Laden]  │
│ 978-3-16-148410-0              [📷] │            │
│ Barcode scannen oder manuell       │            │
└─────────────────────────────────────┴────────────┘
```

**Elemente**:
- **TextField**: ISBN-Eingabe (mit Scanner-Icon)
- **Scanner-Icon** (📷): Suffix-Icon im TextField
- **Laden-Button** (🔍): Rechts neben TextField

## Datenfluss

### Barcode-Scanner Flow
```
User → Scanner-Icon klicken
  ↓
Kamera öffnen
  ↓
Barcode erkennen
  ↓
ISBN ins Feld setzen
  ↓
_lookupIsbn() aufrufen
  ↓
API-Abfrage
  ↓
Felder ausfüllen
```

### Manuell + Laden Flow
```
User → ISBN eintippen
  ↓
"Laden" Button klicken
  ↓
_lookupIsbn() aufrufen
  ↓
API-Abfrage
  ↓
Felder ausfüllen
```

## Lookup-Logik

### APIs verwendet

**Primary**: Open Library Books API
```
https://openlibrary.org/api/books?bibkeys=ISBN:{isbn}&format=json&jscmd=data
```

**Fallback**: Google Books API
```
https://www.googleapis.com/books/v1/volumes?q=isbn:{isbn}
```

**Implementierung**: [isbn_service.dart](../api/isbn-service.md)

### Autofill-Strategie

**Smart Autofill** - Nur leere Felder werden gefüllt:

```dart
// ISBN wird immer aktualisiert (bereinigt)
_isbnController.text = bookInfo['isbn'] ?? isbn;

// Titel nur wenn leer
if (bookInfo['title'] != null && _titelController.text.isEmpty) {
  _titelController.text = bookInfo['title']!;
}

// Autor nur wenn leer
if (bookInfo['author'] != null && _autorController.text.isEmpty) {
  _autorController.text = bookInfo['author']!;
}
```

**Vorteil**:
- User-Eingaben werden nicht überschrieben
- Perfekt für Edit-Screen
- Mehrfacher Lookup möglich ohne Datenverlust

### Geladene Daten

| Feld | Quelle | Überschreibt |
|------|--------|--------------|
| **ISBN** | API (bereinigt) | ✅ Immer |
| **Titel** | API | ⚠️ Nur wenn leer |
| **Autor** | API | ⚠️ Nur wenn leer |
| **Cover** | Nicht automatisch | ❌ Manuell |

**Hinweis**: Cover muss separat über "Cover laden" Button geladen werden (nur wenn ISBN vorhanden).

## Implementierung

### Add Book Screen

**Datei**: `lib/screens/add_book_screen.dart`

**Methoden**:
```dart
/// Öffnet den Barcode-Scanner
Future<void> _scanBarcode() async {
  final isbn = await Navigator.push<String>(...);
  if (isbn == null) return;

  _isbnController.text = isbn;
  await _lookupIsbn();
}

/// Lädt Buchdaten anhand der eingegebenen ISBN
Future<void> _lookupIsbn() async {
  final isbn = _isbnController.text.trim();

  if (isbn.isEmpty) {
    // Warnung anzeigen
    return;
  }

  // Loading zeigen
  showDialog(...);

  // API-Call
  final bookInfo = await IsbnService.instance.lookup(isbn);

  // Loading schließen
  Navigator.pop(context);

  if (bookInfo == null) {
    // Fehler-Message
    return;
  }

  // Felder füllen
  _isbnController.text = bookInfo['isbn'] ?? isbn;
  if (bookInfo['title'] != null && _titelController.text.isEmpty) {
    _titelController.text = bookInfo['title']!;
  }
  // ...

  // Success-Message
}
```

### Edit Book Screen

**Datei**: `lib/screens/edit_book_screen.dart`

**Identische Implementierung** wie Add Book Screen.

### Barcode-Scanner Widget

**Klasse**: `_BarcodeScannerScreen` (private, in beiden Screen-Dateien)

**Features**:
- Vollbild-Kamera
- Overlay mit Frame
- Flashlight-Toggle
- Automatische Erkennung
- Schließt automatisch nach Scan

**Code**:
```dart
MobileScanner(
  controller: cameraController,
  onDetect: (capture) {
    if (_scanned) return;

    final barcode = capture.barcodes.first;
    if (barcode.rawValue != null) {
      setState(() => _scanned = true);
      Navigator.pop(context, barcode.rawValue);
    }
  },
)
```

## Fehlerbehandlung

### Validierung

**Keine ISBN eingegeben**:
```
SnackBar: "Bitte zuerst eine ISBN eingeben" (Orange)
```

**ISBN nicht gefunden**:
```
SnackBar: "Keine Buchdaten für diese ISBN gefunden" (Orange)
```

**Erfolg**:
```
SnackBar: "✓ Buchdaten geladen" (Grün, 2s)
```

### Edge Cases

| Fall | Verhalten |
|------|-----------|
| Leeres ISBN-Feld | Warnung, kein API-Call |
| Ungültige ISBN | API gibt null zurück → Warnung |
| Network Error | API wirft Exception → Warnung |
| Timeout (10s) | Exception → Warnung |
| API down | null zurück → Warnung |

### Loading State

```dart
showDialog(
  context: context,
  barrierDismissible: false,  // User kann nicht abbrechen
  builder: (context) => const Center(
    child: CircularProgressIndicator(),
  ),
);
```

**Hinweis**: Dialog wird immer geschlossen, auch bei Fehler.

## ISBN-Format

### Unterstützte Formate

- **ISBN-10**: `3-608-93831-7` oder `3608938317`
- **ISBN-13**: `978-3-608-93831-4` oder `9783608938314`

### Bereinigung

Services bereinigen ISBN automatisch:
```dart
final cleanIsbn = isbn.replaceAll(RegExp(r'[^0-9]'), '');
```

**Vorher**: `978-3-608-93831-4`
**Nachher**: `9783608938314`

## Performance

### API-Calls

**Timeout**: 10 Sekunden
```dart
await http.get(url).timeout(const Duration(seconds: 10));
```

**Fallback-Chain**:
1. Open Library API (~500ms)
2. Falls null → Google Books API (~500ms)
3. Falls null → Fehler

**Gesamt**: Max 20 Sekunden (sehr selten)

### Caching

Aktuell: **Kein Caching**

**Zukünftig** (optional):
- In-Memory Cache für Session
- SQLite Cache für häufige ISBNs

## Berechtigungen

### Android

**Datei**: `android/app/src/main/AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" />
```

### iOS

**Datei**: `ios/Runner/Info.plist`

```xml
<key>NSCameraUsageDescription</key>
<string>Benötigt Kamera-Zugriff zum Scannen von ISBN-Barcodes</string>
```

## Testing

### Manuelle Tests

**Test-ISBNs**:
- ✅ Gültig: `9783608938314` (Der Hobbit)
- ✅ Gültig: `9780747532743` (Harry Potter)
- ❌ Ungültig: `0000000000000`
- ❌ Ungültig: `abc123`

**Szenarien**:
1. Barcode scannen → Daten laden
2. ISBN manuell eingeben → "Laden" klicken
3. Leeres Feld → "Laden" klicken → Warnung
4. Ungültige ISBN → "Laden" klicken → Warnung
5. ISBN ändern im Edit-Screen → Titel/Autor bleiben
6. Zweimaliges Laden derselben ISBN

### Unit Tests (zukünftig)

```dart
test('ISBN lookup returns book data', () async {
  final result = await IsbnService.instance.lookup('9783608938314');
  expect(result, isNotNull);
  expect(result!['title'], isNotEmpty);
});

test('Invalid ISBN returns null', () async {
  final result = await IsbnService.instance.lookup('invalid');
  expect(result, isNull);
});
```

## Troubleshooting

### Scanner öffnet nicht

**Problem**: Kamera-Permission fehlt

**Lösung**:
1. App-Einstellungen öffnen
2. Berechtigungen → Kamera erlauben
3. App neu starten

### Keine Daten gefunden

**Mögliche Ursachen**:
- ISBN existiert nicht in API-Datenbanken
- Sehr alte/neue Bücher
- Selbstpublizierte Bücher
- Regionale ISBNs

**Lösung**: Daten manuell eingeben

### Timeout

**Problem**: Netzwerk zu langsam/instabil

**Lösung**:
- Bessere Verbindung nutzen
- Später nochmal versuchen
- Manuell eingeben

### Cover nicht automatisch geladen

**Expected**: Cover muss separat geladen werden

**Workflow**:
1. ISBN eingeben/scannen → Titel/Autor laden
2. Buch speichern
3. Buch öffnen
4. "Cover laden" Button → Cover downloaden

## Zukünftige Erweiterungen

### Geplant

- [ ] **Bulk ISBN Import**: Mehrere ISBNs auf einmal
- [ ] **ISBN-Cache**: Häufige ISBNs im Cache
- [ ] **Cover Auto-Download**: Cover automatisch mit laden
- [ ] **Offline-Modus**: Lokale ISBN-Datenbank
- [ ] **Mehr APIs**: Amazon, WorldCat, etc.
- [ ] **ISBN-13 ↔ ISBN-10**: Automatische Konvertierung

### Ideen

- **ISBN-Vorschläge**: Ähnliche ISBNs anzeigen
- **Batch-Scan**: Mehrere Bücher hintereinander scannen
- **History**: Zuletzt gescannte ISBNs
- **Favorites**: Häufig genutzte ISBNs

## Siehe auch

- [ISBN Service API](../api/isbn-service.md)
- [Cover Service API](../api/cover-service.md)
- [Add Book Screen](../api/add-book-screen.md)
- [Edit Book Screen](../api/edit-book-screen.md)

---

**Letzte Aktualisierung**: 2026-07-17
**Version**: 1.1.0 (Laden-Button hinzugefügt)
