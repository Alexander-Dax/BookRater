# Rating-System

Das Rating-System ist das Kernfeature der BookRater-App.

## Übersicht

Anstatt Bücher direkt mit 1-10 zu bewerten, verwendet BookRater **Paarvergleiche** kombiniert mit mathematischen Algorithmen für objektive, konsistente Ratings.

## Workflow

```
1. Neues Buch hinzufügen
   ↓
2. Initial-Rating wählen (oder überspringen)
   ↓
3. Paarvergleiche durchführen
   ↓
4. Galloping Search findet Position
   ↓
5. PAVA-Algorithmus berechnet finale Ratings
   ↓
6. Re-Spacing für konsistente Abstände
   ↓
7. Buch in Datenbank gespeichert
```

## Komponenten

### 1. Initial Rating (Optional)

**Screen**: `AddBookScreen`

User kann ein grobes Initial-Rating (0-10) wählen.

**Zweck**:
- Startpunkt für Galloping Search
- Weniger Vergleiche nötig
- Kann übersprungen werden → Random Comparisons

**Code**:
```dart
double _rating = 6.0; // Default: Mitte

Slider(
  value: _rating,
  min: 0.0,
  max: 10.0,
  divisions: 100,
  onChanged: (value) => setState(() => _rating = value),
)
```

### 2. Paarvergleiche

**Screen**: `ComparisonScreen`

**Algorithmus**: Galloping Search (siehe `ComparisonService`)

**UI**:
```
┌──────────────────────────────┐
│  Vergleiche Buch A mit Buch B  │
├──────────────────────────────┤
│  [Cover A]     VS    [Cover B] │
│  Titel A              Titel B  │
│                                │
│  [Links besser] [Gleich] [Rechts besser] │
└──────────────────────────────┘
```

**Optionen**:
- **Links ist besser**: Neues Buch > Vergleichsbuch
- **Gleich gut**: Neues Buch ≈ Vergleichsbuch
- **Rechts ist besser**: Neues Buch < Vergleichsbuch

### 3. Galloping Search

**Datei**: `lib/services/comparison_service.dart`

**Klasse**: `Inserter` oder `RandomInserter`

#### Inserter (mit Initial Rating)

**Algorithmus**:
1. **Seed-Index berechnen**: Binary Search basierend auf Initial-Rating
2. **Galloping Phase**:
   - Exponentiell nach links/rechts suchen (Schrittweite verdoppeln)
   - Bis Grenze gefunden
3. **Binary Search Phase**:
   - Im gefundenen Bereich binäre Suche
   - Bis Position exakt

**Komplexität**: O(log n)

**Beispiel**:
```
Liste: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
Neues Buch Rating: ~6.5

1. Seed bei Index 6 (Rating 7)
2. Vergleich: Neu > 7? → Nein, nach links
3. Gallop links: Index 5, 4, 2 (Schrittweite: 1, 2, 4)
4. Grenze gefunden: zwischen 5 und 7
5. Binary Search: zwischen Index 5 und 6
6. Position gefunden: Index 6
```

#### RandomInserter (ohne Initial Rating)

**Algorithmus**:
- Random Vergleiche innerhalb des möglichen Bereichs
- Bereich wird mit jedem Vergleich kleiner
- Bis nur noch eine Position übrig

**Nachteil**: Mehr Vergleiche als Inserter

### 4. PAVA-Algorithmus

**Datei**: `lib/services/rating_service.dart`

**Method**: `respace()`

**Zweck**: Pool-Adjacent-Violators Algorithm für isotonische Regression

**Problem**:
Nach dem Einsortieren können Ratings inkonsistent sein:
```
Vor PAVA: [5.0, 5.5, 5.3, 6.0, 7.0]
          ↑        ↑    ↑
          Nicht monoton steigend!
```

**Lösung**:
PAVA erzeugt beste nicht-fallende Approximation:
```
Nach PAVA: [5.0, 5.4, 5.4, 6.0, 7.0]
           ↑        ↑    ↑
           Monoton steigend, nah an Original
```

**Algorithmus**:
1. Durchlaufe Ratings von links nach rechts
2. Falls Rating[i] > Rating[i+1]: Merge zu Durchschnitt
3. Wiederhole bis keine Verletzungen mehr

**Code**:
```dart
List<double> _pava(List<double> targets) {
  final blocks = <List<double>>[];

  for (final y in targets) {
    blocks.add([y, 1.0]); // [summe, anzahl]

    // Merge violators
    while (blocks.length >= 2) {
      final prevAvg = blocks[blocks.length - 2][0] / blocks[blocks.length - 2][1];
      final currAvg = blocks[blocks.length - 1][0] / blocks[blocks.length - 1][1];

      if (prevAvg > currAvg) {
        // Merge
        final sum = blocks[blocks.length - 1][0] + blocks[blocks.length - 2][0];
        final count = blocks[blocks.length - 1][1] + blocks[blocks.length - 2][1];
        blocks.removeLast();
        blocks[blocks.length - 1] = [sum, count];
      } else {
        break;
      }
    }
  }

  // Expandiere zurück
  return _expandBlocks(blocks);
}
```

### 5. Re-Spacing

**Modi**:

#### Soft Mode (Standard)
- PAVA + Mindestabstand (0.05)
- Respektiert User-Präferenzen
- Korrigiert nur Widersprüche

#### Even Mode
- Gleichmäßige Verteilung zwischen Min und Max
- Ignoriert Bauch-Ratings
- Mathematisch "reiner"

**Code**:
```dart
static List<double> respace(
  List<double> targetsAsc, {
  RespaceMode mode = RespaceMode.soft,
  double minGapValue = 0.05,
}) {
  if (mode == RespaceMode.even) {
    // Gleichmäßig verteilen
    return _evenDistribution(targetsAsc);
  } else {
    // PAVA + Mindestabstand
    final v = _pava(targetsAsc);
    return _enforceGap(v, minGapValue);
  }
}
```

**Mindestabstand**: 0.05
- Verhindert dass Bücher zu nah beieinander liegen
- Bei 100+ Büchern noch genug Platz auf 0-10 Skala

### 6. Tier-Zuordnung

**Datei**: `lib/utils/constants.dart`

**Tiers**:
```dart
const List<TierConfig> tiers = [
  TierConfig(name: 'S', minRating: 9.0,  maxRating: 10.0),
  TierConfig(name: 'A', minRating: 7.5,  maxRating: 8.99),
  TierConfig(name: 'B', minRating: 6.0,  maxRating: 7.49),
  TierConfig(name: 'C', minRating: 4.0,  maxRating: 5.99),
  TierConfig(name: 'D', minRating: 2.0,  maxRating: 3.99),
  TierConfig(name: 'F', minRating: 0.0,  maxRating: 1.99),
];
```

## Datenfluss

```
AddBookScreen
  ↓ (Book mit Initial-Rating)
ComparisonScreen
  ↓ (User-Vergleiche)
ComparisonService.Inserter
  ↓ (Position gefunden)
Temporäres Rating zuweisen
  ↓ (Liste mit neuem Buch)
RatingService.respace()
  ↓ (PAVA + Mindestabstand)
Finale Ratings
  ↓
DatabaseService.insertBook()
  ↓
In DB gespeichert
```

## Beispiel-Szenario

### Situation
- Existierende Bücher: 5 Bücher mit Ratings [3.0, 5.0, 6.5, 8.0, 9.0]
- Neues Buch: "Der Hobbit"
- Initial-Rating: 7.0

### Ablauf

1. **Seed-Index**: 7.0 liegt zwischen 6.5 und 8.0 → Index 3

2. **Erster Vergleich** (mit Buch bei Index 3, Rating 8.0):
   - "Der Hobbit" vs "Harry Potter" (8.0)
   - User: "Der Hobbit ist besser"
   - → Nach rechts suchen

3. **Zweiter Vergleich** (Index 4, Rating 9.0):
   - "Der Hobbit" vs "Herr der Ringe" (9.0)
   - User: "Herr der Ringe ist besser"
   - → Grenze gefunden: zwischen Index 3 und 4

4. **Binary Search**:
   - Nur 2 Positionen: vor oder nach Index 3
   - Bereits fertig durch Vergleiche
   - → Position: Index 4 (zwischen 8.0 und 9.0)

5. **Temporäres Rating**: 8.5 (Mitte zwischen 8.0 und 9.0)

6. **PAVA Re-Spacing**:
   - Input: [3.0, 5.0, 6.5, 8.0, 8.5, 9.0]
   - PAVA: [3.0, 5.0, 6.5, 8.0, 8.5, 9.0] (schon monoton)
   - Mindestabstand prüfen: Alle ≥ 0.05 ✓
   - Output: [3.0, 5.0, 6.5, 8.0, 8.5, 9.0]

7. **Finale Ratings**:
   - "Der Hobbit" hat Rating 8.5 (A-Tier)
   - Alle anderen Bücher unverändert

## Edge Cases

### Erstes Buch
- Keine Vergleiche möglich
- Rating wird direkt übernommen
- Position 0

### Alle Vergleiche "Gleich"
- Buch bekommt Rating des Vergleichsbuchs
- Position direkt dahinter

### Sehr viele Bücher (100+)
- Galloping Search bleibt effizient (O(log n))
- PAVA kann alle Ratings minimal anpassen
- Mindestabstand 0.05 → Max 200 Bücher auf 0-10 Skala

### Rating außerhalb 0-10
- PAVA clampt automatisch auf 0-10
- `_enforceGap()` respektiert Grenzen

## Performance

**Vergleiche pro Einsortierung**:
- Best Case: O(log n) = ~7 Vergleiche bei 100 Büchern
- Average Case: O(log n)
- Worst Case: O(log n)

**PAVA-Laufzeit**:
- O(n) für n Bücher
- Bei 100 Büchern: < 1ms

**Gesamt**: Sehr performant, auch bei vielen Büchern

## Konfiguration

**Datei**: `lib/utils/constants.dart`

```dart
// Mindestabstand zwischen Ratings
const double minGap = 0.05;

// Re-Spacing Modus
enum RespaceMode { soft, even }
const RespaceMode defaultRespaceMode = RespaceMode.soft;
```

## Testing

### Manuelle Tests
1. Füge 10 Bücher hinzu mit verschiedenen Ratings
2. Prüfe dass alle Ratings monoton steigend sind
3. Prüfe dass Mindestabstand eingehalten wird
4. Teste Edge Cases (erstes Buch, alle gleich, etc.)

### Unit Tests (zukünftig)
- `rating_service_test.dart`
- `comparison_service_test.dart`

## Siehe auch

- [Comparison Service API](../api/comparison-service.md)
- [Rating Service API](../api/rating-service.md)
- [Architecture Decisions](../architecture/decisions.md#adr-003-pava-algorithmus-für-rating-spacing)

---

**Letzte Aktualisierung**: 2026-07-17
