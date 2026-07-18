import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/media_type.dart';
import '../services/database_service.dart';
import '../services/language_service.dart';
import '../widgets/book_cover.dart';
import 'add_book_screen.dart';
import 'add_manga_screen.dart';
import 'comparison_screen.dart';
import 'edit_book_screen.dart';
import 'import_export_screen.dart';
import 'theme_selection_screen.dart';
import 'tierlist_screen.dart';

/// Hauptseite: Zeigt die Liste aller Bücher
class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final LanguageService languageService;

  const HomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.languageService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _db = DatabaseService.instance;
  List<Book> _books = [];
  bool _isLoading = true;

  String t(String key) => widget.languageService.t(key);

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  /// Lädt alle Bücher aus der Datenbank
  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);
    final books = await _db.getAllBooks();
    setState(() {
      _books = books;
      _isLoading = false;
    });
  }

  /// Zeigt Dialog zur Auswahl des Medientyps (Buch oder Manga)
  Future<void> _showAddMediaDialog() async {
    final mediaType = await showDialog<MediaType>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('add_media_title')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.book, size: 40),
              title: Text(t('add_book_option')),
              subtitle: Text(t('add_book_subtitle')),
              onTap: () => Navigator.pop(context, MediaType.book),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.auto_stories, size: 40),
              title: Text(t('add_manga_option')),
              subtitle: Text(t('add_manga_subtitle')),
              onTap: () => Navigator.pop(context, MediaType.manga),
            ),
          ],
        ),
      ),
    );

    if (mediaType == null) return;

    if (mediaType == MediaType.book) {
      await _addBook();
    } else {
      await _addManga();
    }
  }

  /// Startet den Prozess zum Hinzufügen eines neuen Buches
  Future<void> _addBook() async {
    // 1. Öffne AddBookScreen für Metadaten + Start-Rating
    final addResult = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddBookScreen(),
      ),
    );

    if (addResult == null) return; // Abgebrochen

    final Book newBook = addResult['book'] as Book;
    final bool skipRating = addResult['skipRating'] as bool;

    // 2. Öffne ComparisonScreen für Paarvergleiche
    if (!mounted) return;
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => ComparisonScreen(
          newBook: newBook,
          useRandomComparison: skipRating,
        ),
      ),
    );

    if (result == null) return; // Abgebrochen

    // 3. Zeige Erfolgs-Meldung
    if (!mounted) return;
    final savedBook = result['book'] as Book;
    final changed = result['changed'] as int;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✓ "${savedBook.titel}" hinzugefügt! '
          '${changed > 0 ? '$changed ${changed == 1 ? 'Buch' : 'Bücher'} neu bewertet.' : 'Keine Anpassungen nötig.'}',
        ),
        duration: const Duration(seconds: 3),
      ),
    );

    // 4. Liste neu laden
    _loadBooks();
  }

  /// Startet den Prozess zum Hinzufügen einer neuen Manga-Serie
  Future<void> _addManga() async {
    // 1. Öffne AddMangaScreen für Metadaten
    final addResult = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => AddMangaScreen(languageService: widget.languageService),
      ),
    );

    if (addResult == null) return; // Abgebrochen

    final Book newManga = addResult['book'] as Book;
    final bool skipRating = addResult['skipRating'] as bool;

    // 2. Öffne ComparisonScreen für Paarvergleiche
    if (!mounted) return;
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => ComparisonScreen(
          newBook: newManga,
          useRandomComparison: skipRating,
        ),
      ),
    );

    if (result == null) return; // Abgebrochen

    // 3. Zeige Erfolgs-Meldung
    if (!mounted) return;
    final savedManga = result['book'] as Book;
    final changed = result['changed'] as int;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✓ "${savedManga.titel}" hinzugefügt! '
          '${changed > 0 ? '$changed ${changed == 1 ? 'Buch' : 'Manga'} neu bewertet.' : 'Keine Anpassungen nötig.'}',
        ),
        duration: const Duration(seconds: 3),
      ),
    );

    // 4. Liste neu laden
    _loadBooks();
  }

  /// Öffnet EditBookScreen zum Bearbeiten eines Buches
  Future<void> _editBook(Book book) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditBookScreen(book: book),
      ),
    );

    if (result == null) return;

    // Erfolgs-Meldung
    if (!mounted) return;

    if (result['deleted'] == true) {
      final titel = result['titel'] as String;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ "$titel" gelöscht'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (result['changed'] == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ "${book.titel}" aktualisiert'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      final changed = result['changed'] as int;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✓ "${book.titel}" neu einsortiert! '
            '${changed > 0 ? '$changed ${changed == 1 ? 'Buch' : 'Bücher'} neu bewertet.' : ''}',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    // Liste neu laden
    _loadBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t('app_title')),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Prominent Tier-List Button
          IconButton(
            icon: const Icon(Icons.emoji_events),
            iconSize: 28,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TierListScreen(languageService: widget.languageService),
                ),
              );
            },
            tooltip: t('show_tierlist'),
          ),
          // Hamburger Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: t('more'),
            onSelected: (value) {
              switch (value) {
                case 'refresh':
                  _loadBooks();
                  break;
                case 'import_export':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImportExportScreen(languageService: widget.languageService),
                    ),
                  ).then((_) => _loadBooks());
                  break;
                case 'theme':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ThemeSelectionScreen(),
                    ),
                  );
                  break;
                case 'dark_mode':
                  widget.onToggleTheme();
                  break;
                case 'de':
                case 'en':
                  widget.languageService.setLanguage(value);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    const Icon(Icons.refresh),
                    const SizedBox(width: 12),
                    Text(t('refresh')),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'import_export',
                child: Row(
                  children: [
                    const Icon(Icons.import_export),
                    const SizedBox(width: 12),
                    Text(t('import_export')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'theme',
                child: Row(
                  children: [
                    const Icon(Icons.palette),
                    const SizedBox(width: 12),
                    Text(t('theme_selection')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'dark_mode',
                child: Row(
                  children: [
                    Icon(
                      Theme.of(context).brightness == Brightness.dark
                          ? Icons.light_mode
                          : Icons.dark_mode,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      Theme.of(context).brightness == Brightness.dark
                          ? t('light_mode')
                          : t('dark_mode'),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: widget.languageService.currentLanguage == 'de' ? 'en' : 'de',
                child: Row(
                  children: [
                    const Icon(Icons.language),
                    const SizedBox(width: 12),
                    Text(
                      widget.languageService.currentLanguage == 'de'
                          ? '🇬🇧 English'
                          : '🇩🇪 Deutsch',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _books.isEmpty
              ? _buildEmptyState()
              : _buildBookList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMediaDialog,
        tooltip: 'Hinzufügen',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Zeigt einen Platzhalter wenn keine Bücher vorhanden sind
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            t('no_books_yet'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            t('add_first_book'),
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  /// Zeigt die Liste der Bücher
  Widget _buildBookList() {
    return Column(
      children: [
        // Header mit Anzahl
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Row(
            children: [
              Text(
                '${_books.length} ${_books.length == 1 ? t('books_count_single') : t('books_count_plural')}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              // Später: Filter-Button
            ],
          ),
        ),
        // Bücherliste
        Expanded(
          child: ListView.builder(
            itemCount: _books.length,
            itemBuilder: (context, index) {
              final book = _books[index];
              return _buildBookCard(book);
            },
          ),
        ),
      ],
    );
  }

  /// Einzelne Buch-Karte
  Widget _buildBookCard(Book book) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () => _editBook(book),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Cover
              BookCover(
                book: book,
                width: 40,
                height: 60,
              ),
              const SizedBox(width: 12),
              // Rating Badge
              CircleAvatar(
                backgroundColor: _getRatingColor(book.rating),
                radius: 18,
                child: Text(
                  book.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Title and Author
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.titel,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (book.autor != null && book.autor!.isNotEmpty)
                      Text(
                        book.autor!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
              // Year
              if (book.jahrGelesen != null)
                Text(
                  book.jahrGelesen.toString(),
                  style: TextStyle(color: Colors.grey[600]),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bestimmt die Farbe basierend auf dem Rating
  Color _getRatingColor(double rating) {
    if (rating >= 9.0) return Colors.amber[700]!; // Gold (S-Tier)
    if (rating >= 7.5) return Colors.grey[600]!; // Silber (A-Tier)
    if (rating >= 6.0) return Colors.brown[400]!; // Bronze (B-Tier)
    if (rating >= 4.0) return Colors.blueGrey; // Grau (C-Tier)
    if (rating >= 2.0) return Colors.brown[300]!; // Braun (D-Tier)
    return Colors.red[400]!; // Rot (F-Tier)
  }

}
