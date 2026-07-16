/// Konstanten für das Buch-Rating-System

/// Mindestabstand zwischen zwei benachbarten Ratings beim Glätten.
/// 0.05 ist fein genug für mehrere hundert Bücher und hält Zahlen "ruhig".
const double minGap = 0.05;

/// Re-Spacing-Modus: "soft" (Standard) hält sich nah an deine Bauch-Ratings
/// und korrigiert nur Widersprüche. "even" verteilt gleichmäßig zwischen
/// den Endpunkten (reiner, aber überschreibt das Bauchgefühl stärker).
enum RespaceMode { soft, even }

const RespaceMode defaultRespaceMode = RespaceMode.soft;

/// Tier-Kategorien für die visuelle Darstellung
class TierConfig {
  final String name;
  final double minRating;
  final double maxRating;
  final int color; // Flutter Color als int

  const TierConfig({
    required this.name,
    required this.minRating,
    required this.maxRating,
    required this.color,
  });
}

/// Tier-Definitionen (S-Tier = beste, F-Tier = schlechteste)
const List<TierConfig> tiers = [
  TierConfig(name: 'S', minRating: 9.0, maxRating: 10.0, color: 0xFFFFD700), // Gold
  TierConfig(name: 'A', minRating: 7.5, maxRating: 8.99, color: 0xFFC0C0C0), // Silber
  TierConfig(name: 'B', minRating: 6.0, maxRating: 7.49, color: 0xFFCD7F32), // Bronze
  TierConfig(name: 'C', minRating: 4.0, maxRating: 5.99, color: 0xFF90A4AE), // Grau
  TierConfig(name: 'D', minRating: 2.0, maxRating: 3.99, color: 0xFFBCAAA4), // Braun
  TierConfig(name: 'F', minRating: 0.0, maxRating: 1.99, color: 0xFFEF5350), // Rot
];

/// Datenbank-Konfiguration
const String databaseName = 'book_rater.db';
const int databaseVersion = 2; // Erhöht für ISBN + Cover-URL
const String booksTable = 'books';
