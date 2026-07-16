import 'package:flutter/material.dart';
import '../utils/translations.dart';

/// Service zur Verwaltung der App-Sprache
class LanguageService extends ChangeNotifier {
  String _currentLanguage = 'de'; // Default: Deutsch

  String get currentLanguage => _currentLanguage;

  AppTranslations get translations => AppTranslations(_currentLanguage);

  /// Sprache ändern
  void setLanguage(String languageCode) {
    if (AppTranslations.supportedLanguages.contains(languageCode)) {
      _currentLanguage = languageCode;
      notifyListeners();
    }
  }

  /// Sprache umschalten (Deutsch <-> English)
  void toggleLanguage() {
    _currentLanguage = _currentLanguage == 'de' ? 'en' : 'de';
    notifyListeners();
  }

  /// Übersetzung abrufen
  String t(String key) {
    return translations.get(key);
  }
}
