/// Übersetzungen für die App
class AppTranslations {
  final String languageCode;

  AppTranslations(this.languageCode);

  static final Map<String, Map<String, String>> _translations = {
    // Deutsch
    'de': {
      // General
      'app_title': 'Buch-Ranking',
      'ok': 'OK',
      'cancel': 'Abbrechen',
      'close': 'Schließen',
      'delete': 'Löschen',
      'save': 'Speichern',
      'yes': 'Ja',
      'no': 'Nein',
      'understood': 'Verstanden',
      'refresh': 'Aktualisieren',

      // Home Screen
      'no_books_yet': 'Noch keine Bücher',
      'add_first_book': 'Tippe auf + um dein erstes Buch hinzuzufügen',
      'books_count_single': 'Buch',
      'books_count_plural': 'Bücher',
      'toggle_theme': 'Theme umschalten',
      'show_tierlist': 'Tier-List anzeigen',
      'more_options': 'Weitere Optionen',
      'add_book': 'Buch hinzufügen',
      'csv_export': 'CSV Export',
      'csv_import': 'CSV Import',

      // Book Details
      'title': 'Titel',
      'author': 'Autor',
      'isbn': 'ISBN',
      'word_count': 'Wortzahl',
      'year_read': 'Jahr gelesen',
      'rating': 'Rating',
      'tier': 'Tier',
      'notes': 'Notizen',

      // Messages
      'book_added': 'hinzugefügt!',
      'book_updated': 'aktualisiert',
      'book_deleted': 'gelöscht',
      'book_reordered': 'neu einsortiert!',
      'books_updated': 'neu bewertet.',
      'no_adjustments': 'Keine Anpassungen nötig.',
      'export_failed': 'Export fehlgeschlagen',
      'books_exported': 'Bücher exportiert nach:',
      'import_failed': 'Import fehlgeschlagen',

      // Tier List
      'tierlist': 'Tier-List',
      'tier_explanation': 'Tier-Erklärung',
      'statistics': 'Statistik',
      'total': 'Gesamt',
      'average_rating': 'Ø Rating',
      'no_books_in_tier': 'Keine Bücher in diesem Tier',
      'tier_system': 'Tier-System',
      'tier_intro': 'Die Bücher werden basierend auf ihrem Rating in Tiers eingeteilt:',

      // Tier Names
      'tier_s': 'Meisterwerke',
      'tier_a': 'Exzellent',
      'tier_b': 'Gut',
      'tier_c': 'Okay',
      'tier_d': 'Schwach',
      'tier_f': 'Schlecht',

      // Add Book Screen
      'add_new_book': 'Neues Buch',
      'book_information': 'Buch-Informationen',
      'title_required': 'Titel (Pflichtfeld)',
      'author_optional': 'Autor (optional)',
      'isbn_optional': 'ISBN (optional)',
      'word_count_optional': 'Wortzahl (optional)',
      'year_read_optional': 'Jahr gelesen (optional)',
      'notes_optional': 'Notizen (optional)',
      'initial_rating': 'Anfangs-Rating',
      'continue': 'Weiter',
      'title_empty_error': 'Titel darf nicht leer sein',

      // Edit Book Screen
      'edit_book': 'Buch bearbeiten',
      'update': 'Aktualisieren',
      'delete_book': 'Buch löschen',
      'delete_confirmation': 'Buch wirklich löschen?',
      'delete_warning': 'Dies kann nicht rückgängig gemacht werden.',
      'metadata_updated': 'Metadaten aktualisiert.',

      // Comparison Screen
      'comparing': 'Vergleiche',
      'with': 'mit',
      'which_better': 'Welches Buch ist besser?',
      'left_better': 'Links ist besser',
      'equal': 'Gleich gut',
      'right_better': 'Rechts ist besser',
      'comparison_done': 'Fertig!',
      'comparisons_made': 'Vergleiche durchgeführt',
      'rating_calculated': 'Rating wurde berechnet:',
      'finish': 'Abschließen',

      // CSV Service
      'no_file_selected': 'Keine Datei ausgewählt',
      'invalid_file_path': 'Dateipfad ungültig',
      'csv_empty': 'CSV-Datei ist leer',
      'csv_no_data': 'CSV-Datei enthält keine Daten',
      'no_valid_books': 'Keine gültigen Bücher in CSV gefunden',
    },

    // English
    'en': {
      // General
      'app_title': 'Book Ranking',
      'ok': 'OK',
      'cancel': 'Cancel',
      'close': 'Close',
      'delete': 'Delete',
      'save': 'Save',
      'yes': 'Yes',
      'no': 'No',
      'understood': 'Understood',
      'refresh': 'Refresh',

      // Home Screen
      'no_books_yet': 'No books yet',
      'add_first_book': 'Tap + to add your first book',
      'books_count_single': 'Book',
      'books_count_plural': 'Books',
      'toggle_theme': 'Toggle theme',
      'show_tierlist': 'Show tier list',
      'more_options': 'More options',
      'add_book': 'Add book',
      'csv_export': 'CSV Export',
      'csv_import': 'CSV Import',

      // Book Details
      'title': 'Title',
      'author': 'Author',
      'isbn': 'ISBN',
      'word_count': 'Word count',
      'year_read': 'Year read',
      'rating': 'Rating',
      'tier': 'Tier',
      'notes': 'Notes',

      // Messages
      'book_added': 'added!',
      'book_updated': 'updated',
      'book_deleted': 'deleted',
      'book_reordered': 'reordered!',
      'books_updated': 'updated.',
      'no_adjustments': 'No adjustments needed.',
      'export_failed': 'Export failed',
      'books_exported': 'Books exported to:',
      'import_failed': 'Import failed',

      // Tier List
      'tierlist': 'Tier List',
      'tier_explanation': 'Tier explanation',
      'statistics': 'Statistics',
      'total': 'Total',
      'average_rating': 'Avg Rating',
      'no_books_in_tier': 'No books in this tier',
      'tier_system': 'Tier System',
      'tier_intro': 'Books are categorized into tiers based on their rating:',

      // Tier Names
      'tier_s': 'Masterpieces',
      'tier_a': 'Excellent',
      'tier_b': 'Good',
      'tier_c': 'Okay',
      'tier_d': 'Weak',
      'tier_f': 'Bad',

      // Add Book Screen
      'add_new_book': 'New Book',
      'book_information': 'Book Information',
      'title_required': 'Title (required)',
      'author_optional': 'Author (optional)',
      'isbn_optional': 'ISBN (optional)',
      'word_count_optional': 'Word count (optional)',
      'year_read_optional': 'Year read (optional)',
      'notes_optional': 'Notes (optional)',
      'initial_rating': 'Initial Rating',
      'continue': 'Continue',
      'title_empty_error': 'Title cannot be empty',

      // Edit Book Screen
      'edit_book': 'Edit Book',
      'update': 'Update',
      'delete_book': 'Delete Book',
      'delete_confirmation': 'Really delete book?',
      'delete_warning': 'This cannot be undone.',
      'metadata_updated': 'Metadata updated.',

      // Comparison Screen
      'comparing': 'Comparing',
      'with': 'with',
      'which_better': 'Which book is better?',
      'left_better': 'Left is better',
      'equal': 'Equal',
      'right_better': 'Right is better',
      'comparison_done': 'Done!',
      'comparisons_made': 'Comparisons made',
      'rating_calculated': 'Rating calculated:',
      'finish': 'Finish',

      // CSV Service
      'no_file_selected': 'No file selected',
      'invalid_file_path': 'Invalid file path',
      'csv_empty': 'CSV file is empty',
      'csv_no_data': 'CSV file contains no data',
      'no_valid_books': 'No valid books found in CSV',
    },
  };

  String get(String key) {
    return _translations[languageCode]?[key] ?? key;
  }

  static List<String> get supportedLanguages => ['de', 'en'];

  static String getLanguageName(String code) {
    switch (code) {
      case 'de':
        return 'Deutsch';
      case 'en':
        return 'English';
      default:
        return code;
    }
  }
}
