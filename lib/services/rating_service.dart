import '../models/book.dart';
import '../utils/constants.dart';

/// Service für das Re-Spacing von Ratings
/// Übersetzt aus der Python-Version (book_ranker.py)
class RatingService {
  /// Pool-Adjacent-Violators Algorithmus (PAVA)
  /// Beste nicht-fallende L2-Annäherung an targets
  static List<double> _pava(List<double> targets) {
    if (targets.isEmpty) return [];

    // Liste von [summe, anzahl] Blöcken
    final List<List<double>> blocks = [];

    for (final y in targets) {
      blocks.add([y, 1.0]);

      // Merge-Phase: Wenn der vorherige Block einen höheren Durchschnitt hat
      while (blocks.length >= 2) {
        final prevAvg = blocks[blocks.length - 2][0] / blocks[blocks.length - 2][1];
        final currAvg = blocks[blocks.length - 1][0] / blocks[blocks.length - 1][1];

        if (prevAvg > currAvg) {
          // Merge der letzten beiden Blöcke
          final sum = blocks[blocks.length - 1][0] + blocks[blocks.length - 2][0];
          final count = blocks[blocks.length - 1][1] + blocks[blocks.length - 2][1];
          blocks.removeLast();
          blocks[blocks.length - 1] = [sum, count];
        } else {
          break;
        }
      }
    }

    // Expandiere die Blöcke zurück zu einer Liste
    final List<double> result = [];
    for (final block in blocks) {
      final avg = block[0] / block[1];
      final count = block[1].round();
      for (int i = 0; i < count; i++) {
        result.add(avg);
      }
    }

    return result;
  }

  /// Erzwingt Mindestabstand zwischen benachbarten Werten
  static List<double> _enforceGap(
    List<double> values,
    double gap, {
    double lo = 0.0,
    double hi = 10.0,
  }) {
    if (values.isEmpty) return [];

    final v = List<double>.from(values);
    final n = v.length;

    // Vorwärts: Mindestabstand sicherstellen
    for (int i = 1; i < n; i++) {
      if (v[i] < v[i - 1] + gap) {
        v[i] = v[i - 1] + gap;
      }
    }

    // Falls oben übergelaufen: Deckel setzen und rückwärts korrigieren
    if (v[n - 1] > hi) {
      v[n - 1] = hi;
      for (int i = n - 2; i >= 0; i--) {
        if (v[i] > v[i + 1] - gap) {
          v[i] = v[i + 1] - gap;
        }
      }
    }

    // Falls unten untergelaufen: Boden setzen und vorwärts korrigieren
    if (v[0] < lo) {
      v[0] = lo;
      for (int i = 1; i < n; i++) {
        if (v[i] < v[i - 1] + gap) {
          v[i] = v[i - 1] + gap;
        }
      }
    }

    return v;
  }

  /// Re-Spacing der Ratings
  ///
  /// [targetsAsc]: Bauch-Ratings in aufsteigender Reihenfolge (schlechteste zuerst)
  /// [mode]: soft (Standard) oder even
  /// [minGapValue]: Mindestabstand zwischen Ratings
  ///
  /// Liefert die finalen Ratings in derselben Reihenfolge
  static List<double> respace(
    List<double> targetsAsc, {
    RespaceMode mode = defaultRespaceMode,
    double minGapValue = minGap,
  }) {
    final n = targetsAsc.length;

    if (n == 0) return [];
    if (n == 1) {
      final val = targetsAsc[0].clamp(0.0, 10.0);
      return [_round2(val)];
    }

    List<double> v;

    if (mode == RespaceMode.even) {
      // Gleichmäßige Verteilung zwischen Endpunkten
      double lo = targetsAsc.first;
      double hi = targetsAsc.last;

      if (hi - lo < minGapValue * (n - 1)) {
        hi = lo + minGapValue * (n - 1);
      }

      v = List.generate(n, (i) => lo + (hi - lo) * i / (n - 1));
    } else {
      // Soft-Modus: PAVA + Mindestabstand
      final clamped = targetsAsc.map((t) => t.clamp(0.0, 10.0)).toList();
      v = _pava(clamped);
      v = _enforceGap(v, minGapValue);
    }

    // Auf 2 Nachkommastellen runden
    v = v.map(_round2).toList();

    // Finale Strenge (0.01) sicherstellen
    v = _enforceGap(v, 0.01);
    v = v.map(_round2).toList();

    return v;
  }

  /// Rundet auf 2 Nachkommastellen
  static double _round2(double val) {
    return (val * 100).roundToDouble() / 100;
  }

  /// Aktualisiert die Ratings einer Buchliste nach dem Einfügen eines neuen Buches
  ///
  /// [booksAsc]: Alle Bücher in aufsteigender Reihenfolge (inklusive neuem Buch)
  ///
  /// Gibt die Anzahl der geänderten Bücher zurück (ohne das neue Buch)
  static int updateRatings(
    List<Book> booksAsc, {
    Book? newBook,
    RespaceMode mode = defaultRespaceMode,
  }) {
    if (booksAsc.isEmpty) return 0;

    // Alte Ratings speichern
    final oldRatings = booksAsc.map((b) => b.rating).toList();

    // Ziel-Ratings = aktuelle Ratings (Bauchgefühl)
    final targets = oldRatings.toList();

    // Neue Ratings berechnen
    final newRatings = respace(targets, mode: mode);

    // Ratings zuweisen
    for (int i = 0; i < booksAsc.length; i++) {
      booksAsc[i] = booksAsc[i].copyWith(rating: newRatings[i]);
    }

    // Zähle geänderte Bücher (ohne das neue Buch)
    int changed = 0;
    for (int i = 0; i < booksAsc.length; i++) {
      if (booksAsc[i] != newBook && (oldRatings[i] - newRatings[i]).abs() >= 0.005) {
        changed++;
      }
    }

    return changed;
  }
}
