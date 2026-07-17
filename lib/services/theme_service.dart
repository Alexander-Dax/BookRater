import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service für die Verwaltung von App-Themes
/// Bietet 8 vordefinierte Farbschemata und persistente Speicherung
class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  static const String _themeKey = 'selected_theme';
  String _selectedThemeId = 'deepPurple';

  /// Gibt die ID des aktuell ausgewählten Themes zurück
  String get selectedThemeId => _selectedThemeId;

  /// Verfügbare Theme-Optionen mit Namen und Farben
  static final Map<String, AppTheme> themes = {
    'deepPurple': AppTheme(
      id: 'deepPurple',
      name: 'Deep Purple',
      seedColor: const Color(0xFF6750A4),
    ),
    'oceanBlue': AppTheme(
      id: 'oceanBlue',
      name: 'Ocean Blue',
      seedColor: const Color(0xFF0077BE),
    ),
    'forestGreen': AppTheme(
      id: 'forestGreen',
      name: 'Forest Green',
      seedColor: const Color(0xFF2E7D32),
    ),
    'sunsetOrange': AppTheme(
      id: 'sunsetOrange',
      name: 'Sunset Orange',
      seedColor: const Color(0xFFE65100),
    ),
    'crimsonRed': AppTheme(
      id: 'crimsonRed',
      name: 'Crimson Red',
      seedColor: const Color(0xFFC62828),
    ),
    'royalIndigo': AppTheme(
      id: 'royalIndigo',
      name: 'Royal Indigo',
      seedColor: const Color(0xFF283593),
    ),
    'teakBrown': AppTheme(
      id: 'teakBrown',
      name: 'Teak Brown',
      seedColor: const Color(0xFF5D4037),
    ),
    'slateGray': AppTheme(
      id: 'slateGray',
      name: 'Slate Gray',
      seedColor: const Color(0xFF455A64),
    ),
  };

  /// Initialisiert den Theme-Service und lädt gespeicherte Präferenzen
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedThemeId = prefs.getString(_themeKey) ?? 'deepPurple';
    notifyListeners();
  }

  /// Setzt das ausgewählte Theme und speichert die Auswahl
  Future<void> setTheme(String themeId) async {
    if (!themes.containsKey(themeId)) return;

    _selectedThemeId = themeId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeId);
    notifyListeners();
  }

  /// Gibt das aktuell ausgewählte Theme zurück
  AppTheme get currentTheme => themes[_selectedThemeId]!;

  /// Erstellt ThemeData für das ausgewählte Theme
  ThemeData getLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: currentTheme.seedColor,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      fontFamily: 'serif',
    );
  }

  /// Erstellt Dark ThemeData für das ausgewählte Theme
  ThemeData getDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: currentTheme.seedColor,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      fontFamily: 'serif',
    );
  }
}

/// Datenklasse für ein App-Theme
class AppTheme {
  final String id;
  final String name;
  final Color seedColor;

  const AppTheme({
    required this.id,
    required this.name,
    required this.seedColor,
  });
}
