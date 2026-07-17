import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/database_service.dart';
import '../services/cover_service.dart';
import '../widgets/book_cover.dart';
import 'comparison_screen.dart';

/// Screen zum Bearbeiten eines vorhandenen Buches
/// Bei Rating-Änderung: Neu-Einsortierung wie bei neuem Buch
class EditBookScreen extends StatefulWidget {
  final Book book;

  const EditBookScreen({super.key, required this.book});

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _db = DatabaseService.instance;
  final CoverService _coverService = CoverService.instance;

  bool _isDownloadingCover = false;

  // Form-Controller
  late final TextEditingController _titelController;
  late final TextEditingController _autorController;
  late final TextEditingController _isbnController;
  late final TextEditingController _jahrController;
  late final TextEditingController _metaController;

  late double _rating;
  late double _originalRating;

  @override
  void initState() {
    super.initState();
    // Initialisiere Controller mit bestehenden Werten
    _titelController = TextEditingController(text: widget.book.titel);
    _autorController = TextEditingController(text: widget.book.autor ?? '');
    _isbnController = TextEditingController(text: widget.book.isbn ?? '');
    _jahrController = TextEditingController(
      text: widget.book.jahrGelesen?.toString() ?? '',
    );
    _metaController = TextEditingController(text: widget.book.meta ?? '');

    _rating = widget.book.rating;
    _originalRating = widget.book.rating;
  }

  @override
  void dispose() {
    _titelController.dispose();
    _autorController.dispose();
    _isbnController.dispose();
    _jahrController.dispose();
    _metaController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Erstelle aktualisiertes Buch
    final updatedBook = widget.book.copyWith(
      titel: _titelController.text.trim(),
      autor: _autorController.text.trim().isEmpty
          ? null
          : _autorController.text.trim(),
      isbn: _isbnController.text.trim().isEmpty
          ? null
          : _isbnController.text.trim(),
      jahrGelesen: _parseIntOrNull(_jahrController.text),
      meta:
          _metaController.text.trim().isEmpty ? null : _metaController.text.trim(),
      rating: _rating,
    );

    // Hat sich das Rating geändert?
    final ratingChanged = (_rating - _originalRating).abs() > 0.01;

    if (!ratingChanged) {
      // Nur Metadaten geändert: Direkt speichern
      await _db.updateBook(updatedBook);
      if (!mounted) return;
      Navigator.pop(context, {'changed': false});
      return;
    }

    // Rating geändert: Buch löschen, neu einsortieren
    await _db.deleteBook(widget.book.id!);

    // Öffne ComparisonScreen für Neu-Einsortierung
    if (!mounted) return;
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => ComparisonScreen(newBook: updatedBook),
      ),
    );

    if (result == null) {
      // Abgebrochen: Altes Buch wiederherstellen
      await _db.insertBook(widget.book);
      if (!mounted) return;
      Navigator.pop(context);
      return;
    }

    // Erfolgreich neu einsortiert
    if (!mounted) return;
    Navigator.pop(context, result);
  }

  int? _parseIntOrNull(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  /// Lädt das Cover für das Buch herunter
  Future<void> _downloadCover() async {
    setState(() => _isDownloadingCover = true);

    try {
      final success = await _coverService.downloadCover(widget.book);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Cover erfolgreich heruntergeladen'),
            duration: Duration(seconds: 2),
          ),
        );
        setState(() {}); // UI aktualisieren
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Kein Cover für diese ISBN gefunden'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Fehler beim Download: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isDownloadingCover = false);
      }
    }
  }

  /// Bestätigungs-Dialog fürs Löschen
  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buch löschen?'),
        content: Text(
          'Möchtest du "${widget.book.titel}" wirklich löschen? '
          'Diese Aktion kann nicht rückgängig gemacht werden.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _db.deleteBook(widget.book.id!);
      if (!mounted) return;
      Navigator.pop(context, {'deleted': true, 'titel': widget.book.titel});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buch bearbeiten'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Lösch-Button
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDelete,
            tooltip: 'Löschen',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Hinweis bei Rating-Änderung
            if (_rating != _originalRating)
              Card(
                color: Colors.amber[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber[800]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Rating geändert: Buch wird neu einsortiert',
                          style: TextStyle(
                            color: Colors.amber[900],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (_rating != _originalRating) const SizedBox(height: 16),

            // Cover-Vorschau + Download
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Cover-Vorschau
                    BookCover(
                      book: widget.book,
                      width: 80,
                      height: 120,
                    ),
                    const SizedBox(width: 16),
                    // Info + Download-Button
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Buchcover',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          if (widget.book.isbn == null || widget.book.isbn!.isEmpty)
                            Text(
                              'ISBN benötigt für automatischen Download',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            )
                          else if (widget.book.coverUrl != null)
                            Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Cover vorhanden',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            )
                          else
                            FilledButton.icon(
                              onPressed: _isDownloadingCover ? null : _downloadCover,
                              icon: _isDownloadingCover
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.download, size: 18),
                              label: Text(
                                _isDownloadingCover ? 'Lädt...' : 'Cover laden',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Titel (Pflichtfeld)
            TextFormField(
              controller: _titelController,
              decoration: const InputDecoration(
                labelText: 'Titel *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Bitte einen Titel eingeben';
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 16),

            // Autor
            TextFormField(
              controller: _autorController,
              decoration: const InputDecoration(
                labelText: 'Autor',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 16),

            // ISBN
            TextFormField(
              controller: _isbnController,
              decoration: const InputDecoration(
                labelText: 'ISBN',
                hintText: '978-3-16-148410-0',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16),

            // Jahr gelesen
            TextFormField(
              controller: _jahrController,
              decoration: const InputDecoration(
                labelText: 'Jahr gelesen',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16),

            // Meta / Notizen
            TextFormField(
              controller: _metaController,
              decoration: const InputDecoration(
                labelText: 'Meta / Notizen',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 24),

            // Rating-Slider
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rating',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _rating,
                            min: 0.0,
                            max: 10.0,
                            divisions: 100,
                            label: _rating.toStringAsFixed(1),
                            onChanged: (value) {
                              setState(() => _rating = value);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 60,
                          child: Text(
                            _rating.toStringAsFixed(1),
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _getRatingColor(_rating),
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    // Tier-Anzeige
                    Center(
                      child: Chip(
                        label: Text(
                          _getTierName(_rating),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: _getRatingColor(_rating),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Submit-Button
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.save),
              label: Text(
                _rating != _originalRating
                    ? 'Speichern & Neu einsortieren'
                    : 'Speichern',
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 8),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 9.0) return Colors.amber[700]!;
    if (rating >= 7.5) return Colors.grey[600]!;
    if (rating >= 6.0) return Colors.brown[400]!;
    if (rating >= 4.0) return Colors.blueGrey;
    if (rating >= 2.0) return Colors.brown[300]!;
    return Colors.red[400]!;
  }

  String _getTierName(double rating) {
    if (rating >= 9.0) return 'S-Tier (Meisterwerk)';
    if (rating >= 7.5) return 'A-Tier (Exzellent)';
    if (rating >= 6.0) return 'B-Tier (Gut)';
    if (rating >= 4.0) return 'C-Tier (Okay)';
    if (rating >= 2.0) return 'D-Tier (Schwach)';
    return 'F-Tier (Schlecht)';
  }
}
