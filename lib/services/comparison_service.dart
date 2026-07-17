import '../models/book.dart';

/// Ergebnis eines Paarvergleichs
enum ComparisonResult {
  better, // Neues Buch ist besser
  worse, // Neues Buch ist schlechter
  equal, // Etwa gleich
}

/// Schrittweiser Suchmotor für die Einsortierung (aus Python übersetzt)
///
/// Verwendung als Generator/Iterator-Ersatz in Dart:
/// - Nutzt eine State-Machine mit moveNext() und current
class _InsertionSearchIterator {
  final int n;
  final int seed;
  int? _current;
  bool _done = false;
  int _state = 0;

  // State-Variablen für den Algorithmus
  int? _lo;
  int? _hi;
  int _step = 1;

  _InsertionSearchIterator(this.n, this.seed);

  bool get isDone => _done;
  int? get current => _current;
  int? result;

  /// Initialisiert den Iterator mit dem ersten Vergleich
  void start() {
    if (n == 0) {
      _done = true;
      result = 0;
      return;
    }

    final s = seed < n ? seed : n - 1;
    _current = s;
    _state = 1; // Warte auf erste Antwort
  }

  /// Verarbeitet eine Antwort und gibt zurück ob fertig
  bool send(ComparisonResult answer) {
    if (_done) return true;

    switch (_state) {
      case 1: // Erste Antwort bei seed
        final s = _current!;

        if (answer == ComparisonResult.equal) {
          result = s;
          _done = true;
          return true;
        }

        if (answer == ComparisonResult.worse) {
          // Nach links galoppieren
          _hi = s;
          _step = 1;
          _lo = s - 1;
          _state = 2; // Galoppiere links
          return _gallopLeft();
        } else {
          // Nach rechts galoppieren
          _lo = s;
          _step = 1;
          _hi = s + 1;
          _state = 3; // Galoppiere rechts
          return _gallopRight();
        }

      case 2: // Galoppiere links
        if (answer == ComparisonResult.equal) {
          result = _current;
          _done = true;
          return true;
        }

        if (answer == ComparisonResult.worse) {
          _hi = _current;
          _step *= 2;
          return _gallopLeft();
        } else {
          // Grenze gefunden
          _lo = _current;
          _state = 4; // Binäre Suche
          return _binarySearch();
        }

      case 3: // Galoppiere rechts
        if (answer == ComparisonResult.equal) {
          result = _current;
          _done = true;
          return true;
        }

        if (answer == ComparisonResult.worse) {
          // Grenze gefunden
          _hi = _current;
          _state = 4; // Binäre Suche
          return _binarySearch();
        } else {
          _lo = _current;
          _step *= 2;
          return _gallopRight();
        }

      case 4: // Binäre Suche
        if (answer == ComparisonResult.equal) {
          result = _current;
          _done = true;
          return true;
        }

        if (answer == ComparisonResult.worse) {
          _hi = _current;
        } else {
          _lo = _current;
        }

        return _binarySearch();
    }

    return false;
  }

  bool _gallopLeft() {
    final s = seed < n ? seed : n - 1;
    _lo = s - _step;

    if (_lo! < 0) {
      _lo = -1;
      _state = 4; // Binäre Suche
      return _binarySearch();
    }

    _current = _lo;
    return false; // Braucht nächsten Vergleich
  }

  bool _gallopRight() {
    final s = seed < n ? seed : n - 1;
    _hi = s + _step;

    if (_hi! >= n) {
      _hi = n;
      _state = 4; // Binäre Suche
      return _binarySearch();
    }

    _current = _hi;
    return false; // Braucht nächsten Vergleich
  }

  bool _binarySearch() {
    final lo = _lo!;
    final hi = _hi!;

    if (hi - lo <= 1) {
      result = hi;
      _done = true;
      return true;
    }

    final mid = (lo + hi) ~/ 2;
    _current = mid;
    return false; // Braucht nächsten Vergleich
  }
}

/// Klick-getriebener Treiber für die Einsortierung
///
/// Verwendung:
/// 1. Erstelle Inserter mit der Buchliste und dem Start-Rating
/// 2. Solange !done: Zeige currentBook und rufe answer() mit dem Ergebnis
/// 3. Wenn done: position enthält den Einfüge-Index
class Inserter {
  final List<Book> booksAsc;
  final Map<int, ComparisonResult> answers = {};

  bool done = false;
  int? position;
  int? currentIndex;

  late _InsertionSearchIterator _iterator;

  Inserter(this.booksAsc, double startRating) {
    final n = booksAsc.length;

    if (n == 0) {
      done = true;
      position = 0;
      return;
    }

    // Seed-Index: Wo würde das Rating rein passen?
    final seed = _seedIndex(startRating, booksAsc.map((b) => b.rating).toList());

    _iterator = _InsertionSearchIterator(n, seed);
    _iterator.start();

    if (_iterator.isDone) {
      done = true;
      position = _iterator.result;
    } else {
      _pump();
    }
  }

  /// Findet den Seed-Index basierend auf dem Rating
  int _seedIndex(double rating, List<double> ratingsAsc) {
    int lo = 0;
    int hi = ratingsAsc.length;

    while (lo < hi) {
      final mid = (lo + hi) ~/ 2;
      if (ratingsAsc[mid] <= rating) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }

    return lo;
  }

  /// Holt den nächsten Index, überspringt bereits beantwortete
  void _pump() {
    while (!_iterator.isDone) {
      currentIndex = _iterator.current;

      // Wenn dieser Index schon beantwortet wurde, automatisch weiter
      if (answers.containsKey(currentIndex)) {
        _iterator.send(answers[currentIndex]!);
      } else {
        // Warte auf Benutzer-Antwort
        return;
      }
    }

    // Fertig
    done = true;
    position = _iterator.result;
    currentIndex = null;
  }

  /// Gibt das aktuell zu vergleichende Buch zurück
  Book? get currentBook {
    if (done || currentIndex == null) return null;
    return booksAsc[currentIndex!];
  }

  /// Verarbeitet eine Antwort und geht zum nächsten Schritt
  void answer(ComparisonResult result) {
    if (done || currentIndex == null) return;

    answers[currentIndex!] = result;
    _iterator.send(result);
    _pump();
  }

  /// Anzahl der bisher gestellten Fragen
  int get questionCount => answers.length;
}

/// Random comparison inserter for books without initial rating
///
/// Uses random comparisons to gradually sort a book into the list
class RandomInserter {
  final List<Book> booksAsc;
  final Map<int, ComparisonResult> answers = {};

  bool done = false;
  int? position;
  int? currentIndex;

  int _lowestBetter = -1; // Index of lowest book that is worse than new book
  int _highestWorse = -1; // Index of highest book that is better than new book

  RandomInserter(this.booksAsc) {
    if (booksAsc.isEmpty) {
      done = true;
      position = 0;
      return;
    }

    _highestWorse = booksAsc.length; // Start: new book could be anywhere
    _pickNextComparison();
  }

  void _pickNextComparison() {
    // Range where the book could be inserted: (_lowestBetter, _highestWorse)
    final rangeSize = _highestWorse - _lowestBetter - 1;

    if (rangeSize <= 0) {
      // Range is narrowed down to a single position
      done = true;
      position = _highestWorse;
      currentIndex = null;
      return;
    }

    // Pick a random book from the remaining range
    final availableIndices = <int>[];
    for (int i = _lowestBetter + 1; i < _highestWorse; i++) {
      if (!answers.containsKey(i)) {
        availableIndices.add(i);
      }
    }

    if (availableIndices.isEmpty) {
      // All books in range have been compared, narrow down based on answers
      _narrowRange();
      if (!done) {
        _pickNextComparison();
      }
      return;
    }

    // Pick random index from available
    final randomIdx = availableIndices[DateTime.now().millisecondsSinceEpoch % availableIndices.length];
    currentIndex = randomIdx;
  }

  void _narrowRange() {
    // Find the actual bounds based on answers
    for (int i = _lowestBetter + 1; i < _highestWorse; i++) {
      if (!answers.containsKey(i)) continue;

      final result = answers[i]!;
      if (result == ComparisonResult.better) {
        // New book is better than book at index i
        if (i > _lowestBetter) {
          _lowestBetter = i;
        }
      } else if (result == ComparisonResult.worse) {
        // New book is worse than book at index i
        if (i < _highestWorse) {
          _highestWorse = i;
        }
      } else {
        // Equal - insert at this position
        done = true;
        position = i;
        return;
      }
    }

    // Check if range is narrowed to single position
    if (_highestWorse - _lowestBetter <= 1) {
      done = true;
      position = _highestWorse;
    }
  }

  /// Gibt das aktuell zu vergleichende Buch zurück
  Book? get currentBook {
    if (done || currentIndex == null) return null;
    return booksAsc[currentIndex!];
  }

  /// Verarbeitet eine Antwort und geht zum nächsten Schritt
  void answer(ComparisonResult result) {
    if (done || currentIndex == null) return;

    answers[currentIndex!] = result;

    if (result == ComparisonResult.equal) {
      done = true;
      position = currentIndex;
      currentIndex = null;
      return;
    }

    if (result == ComparisonResult.better) {
      // New book is better than current book
      if (currentIndex! > _lowestBetter) {
        _lowestBetter = currentIndex!;
      }
    } else {
      // New book is worse than current book
      if (currentIndex! < _highestWorse) {
        _highestWorse = currentIndex!;
      }
    }

    _pickNextComparison();
  }

  /// Anzahl der bisher gestellten Fragen
  int get questionCount => answers.length;
}
