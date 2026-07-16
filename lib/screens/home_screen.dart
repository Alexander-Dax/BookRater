import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/database_service.dart';
import '../utils/test_data.dart';
import '../widgets/book_cover.dart';
import 'add_book_screen.dart';
import 'comparison_screen.dart';
import 'edit_book_screen.dart';
import 'tierlist_screen.dart';

/// Hauptseite: Zeigt die Liste aller Bücher
class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const HomeScreen({super.key, required this.onToggleTheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _db = DatabaseService.instance;
  List<Book> _books = [];
  bool _isLoading = true;

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

  /// Startet den Prozess zum Hinzufügen eines neuen Buches
  Future<void> _addBook() async {
    // 1. Öffne AddBookScreen für Metadaten + Start-Rating
    final Book? newBook = await Navigator.push<Book>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddBookScreen(),
      ),
    );

    if (newBook == null) return; // Abgebrochen

    // 2. Öffne ComparisonScreen für Paarvergleiche
    if (!mounted) return;
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => ComparisonScreen(newBook: newBook),
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
        title: const Text('Buch-Ranking'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Dark Mode Toggle
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: widget.onToggleTheme,
            tooltip: 'Theme umschalten',
          ),
          // Tier-List Button
          IconButton(
            icon: const Icon(Icons.view_list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TierListScreen(),
                ),
              );
            },
            tooltip: 'Tier-List anzeigen',
          ),
          // Test-Daten Button (nur für Entwicklung)
          IconButton(
            icon: const Icon(Icons.science),
            onPressed: () async {
              await addTestBooks();
              _loadBooks();
            },
            tooltip: 'Test-Daten laden',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBooks,
            tooltip: 'Aktualisieren',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _books.isEmpty
              ? _buildEmptyState()
              : _buildBookList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBook,
        tooltip: 'Buch hinzufügen',
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
            'Noch keine Bücher',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tippe auf + um dein erstes Buch hinzuzufügen',
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
                '${_books.length} ${_books.length == 1 ? 'Buch' : 'Bücher'}',
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
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
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
          ],
        ),
        title: Text(
          book.titel,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: book.autor != null && book.autor!.isNotEmpty
            ? Text(book.autor!)
            : null,
        trailing: book.jahrGelesen != null
            ? Text(
                book.jahrGelesen.toString(),
                style: TextStyle(color: Colors.grey[600]),
              )
            : null,
        onTap: () => _editBook(book),
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
