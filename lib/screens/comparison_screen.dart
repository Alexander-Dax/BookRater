import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/comparison_service.dart';
import '../services/database_service.dart';
import '../services/rating_service.dart';

/// Screen für den Paarvergleich beim Einsortieren eines neuen Buches
class ComparisonScreen extends StatefulWidget {
  final Book newBook;
  final bool useRandomComparison;

  const ComparisonScreen({
    super.key,
    required this.newBook,
    this.useRandomComparison = false,
  });

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  final DatabaseService _db = DatabaseService.instance;

  Inserter? _inserter;
  RandomInserter? _randomInserter;
  List<Book> _booksAsc = [];
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _startComparison();
  }

  Future<void> _startComparison() async {
    setState(() => _isLoading = true);

    // Lade alle bestehenden Bücher (aufsteigend sortiert)
    _booksAsc = await _db.getAllBooksAscending();

    if (_booksAsc.isEmpty) {
      // Erstes Buch: Kein Vergleich nötig
      await _saveBook(position: 0);
      return;
    }

    // Starte den Vergleichsprozess
    if (widget.useRandomComparison) {
      // Random comparison mode
      _randomInserter = RandomInserter(_booksAsc);

      if (_randomInserter!.done) {
        await _saveBook(position: _randomInserter!.position!);
        return;
      }
    } else {
      // Seed-based comparison mode
      _inserter = Inserter(_booksAsc, widget.newBook.rating);

      if (_inserter!.done) {
        // Keine Vergleiche nötig (sehr unwahrscheinlich)
        await _saveBook(position: _inserter!.position!);
        return;
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _answer(ComparisonResult result) async {
    if ((_inserter == null && _randomInserter == null) || _isProcessing) return;

    setState(() => _isProcessing = true);

    if (widget.useRandomComparison) {
      _randomInserter!.answer(result);

      if (_randomInserter!.done) {
        await _saveBook(position: _randomInserter!.position!);
      } else {
        setState(() => _isProcessing = false);
      }
    } else {
      _inserter!.answer(result);

      if (_inserter!.done) {
        await _saveBook(position: _inserter!.position!);
      } else {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _saveBook({required int position}) async {
    setState(() => _isProcessing = true);

    // Füge neues Buch an der ermittelten Position ein
    final allBooks = List<Book>.from(_booksAsc);
    allBooks.insert(position, widget.newBook);

    // Re-Spacing: Berechne finale Ratings
    final changedCount = RatingService.updateRatings(
      allBooks,
      newBook: widget.newBook,
    );

    // Speichere das neue Buch in der DB
    final newId = await _db.insertBook(allBooks[position]);
    allBooks[position] = allBooks[position].copyWith(id: newId);

    // Update alle anderen Ratings (falls geändert)
    final booksToUpdate = allBooks.where((b) => b.id != newId).toList();
    if (booksToUpdate.isNotEmpty) {
      await _db.updateRatings(booksToUpdate);
    }

    // Zeige Ergebnis und gehe zurück
    if (!mounted) return;

    Navigator.pop(context, {
      'book': allBooks[position],
      'changed': changedCount,
      'total': allBooks.length,
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Einsortieren...'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final currentBook = widget.useRandomComparison
        ? _randomInserter!.currentBook
        : _inserter!.currentBook;
    if (currentBook == null) {
      return const Scaffold(
        body: Center(child: Text('Fehler: Kein Buch zum Vergleichen')),
      );
    }

    final questionNo = widget.useRandomComparison
        ? _randomInserter!.questionCount + 1
        : _inserter!.questionCount + 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('Vergleich $questionNo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : _buildComparisonContent(currentBook, questionNo),
    );
  }

  Widget _buildComparisonContent(Book currentBook, int questionNo) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Fragen-Fortschritt
            Text(
              'Frage $questionNo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),

            const SizedBox(height: 16),

            // Überschrift
            Text(
              'Welches Buch gefällt dir besser?',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Neues Buch
            _buildBookCard(
              book: widget.newBook,
              label: 'NEU',
              isNew: true,
            ),

            const SizedBox(height: 24),

            // VS
            Text(
              'vs.',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 24),

            // Vergleichs-Buch
            _buildBookCard(
              book: currentBook,
              label: 'Rating: ${currentBook.rating.toStringAsFixed(2)}',
              isNew: false,
            ),

            const SizedBox(height: 32),

            // Antwort-Buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _answer(ComparisonResult.better),
                    icon: const Icon(Icons.arrow_upward),
                    label: const Text('Das NEUE ist besser'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      padding: const EdgeInsets.all(20),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _answer(ComparisonResult.equal),
                    icon: const Icon(Icons.drag_handle),
                    label: const Text('Etwa gleich'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _answer(ComparisonResult.worse),
                    icon: const Icon(Icons.arrow_downward),
                    label: const Text('Das NEUE ist schlechter'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      padding: const EdgeInsets.all(20),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBookCard({
    required Book book,
    required String label,
    required bool isNew,
  }) {
    return Card(
      elevation: isNew ? 4 : 2,
      color: isNew ? Colors.amber[50] : null,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isNew ? Colors.amber[700] : Colors.grey[700],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Titel
            Text(
              '"${book.titel}"',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            if (book.autor != null && book.autor!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                book.autor!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
