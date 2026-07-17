import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/book.dart';
import '../services/isbn_service.dart';

/// Screen zum Hinzufügen eines neuen Buches
class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form-Controller
  final _titelController = TextEditingController();
  final _autorController = TextEditingController();
  final _isbnController = TextEditingController();
  final _jahrController = TextEditingController();
  final _metaController = TextEditingController();
  final _ratingController = TextEditingController();

  double _rating = 6.0;
  bool _skipInitialRating = false;

  @override
  void initState() {
    super.initState();
    // Standard: Aktuelles Jahr
    _jahrController.text = DateTime.now().year.toString();
    // Standard-Rating
    _ratingController.text = _rating.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _titelController.dispose();
    _autorController.dispose();
    _isbnController.dispose();
    _jahrController.dispose();
    _metaController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Erstelle das Buch
    final book = Book(
      titel: _titelController.text.trim(),
      autor: _autorController.text.trim().isEmpty ? null : _autorController.text.trim(),
      isbn: _isbnController.text.trim().isEmpty ? null : _isbnController.text.trim(),
      jahrGelesen: _parseIntOrNull(_jahrController.text),
      meta: _metaController.text.trim().isEmpty ? null : _metaController.text.trim(),
      rating: _skipInitialRating ? 5.0 : _rating, // Use 5.0 as middle value if skipping
    );

    // Zurück zum HomeScreen mit dem Buch und Info ob Rating übersprungen wurde
    Navigator.pop(context, {'book': book, 'skipRating': _skipInitialRating});
  }

  int? _parseIntOrNull(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  /// Öffnet den Barcode-Scanner
  Future<void> _scanBarcode() async {
    final isbn = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const _BarcodeScannerScreen(),
      ),
    );

    if (isbn == null) return;

    // ISBN setzen und Lookup durchführen
    _isbnController.text = isbn;
    await _lookupIsbn();
  }

  /// Lädt Buchdaten anhand der eingegebenen ISBN
  Future<void> _lookupIsbn() async {
    final isbn = _isbnController.text.trim();

    if (isbn.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte zuerst eine ISBN eingeben'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Zeige Loading-Indikator
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Lookup ISBN
    final bookInfo = await IsbnService.instance.lookup(isbn);

    if (!mounted) return;
    Navigator.pop(context); // Schließe Loading-Dialog

    if (bookInfo == null) {
      // Keine Daten gefunden
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keine Buchdaten für diese ISBN gefunden'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Fülle Felder aus
    _isbnController.text = bookInfo['isbn'] ?? isbn;
    if (bookInfo['title'] != null && _titelController.text.isEmpty) {
      _titelController.text = bookInfo['title']!;
    }
    if (bookInfo['author'] != null && _autorController.text.isEmpty) {
      _autorController.text = bookInfo['author']!;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Buchdaten geladen'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neues Buch'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Titel (Pflichtfeld)
            TextFormField(
              controller: _titelController,
              decoration: const InputDecoration(
                labelText: 'Titel *',
                hintText: 'z. B. Der Schatten des Windes',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Bitte einen Titel eingeben';
                }
                return null;
              },
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 16),

            // Autor
            TextFormField(
              controller: _autorController,
              decoration: const InputDecoration(
                labelText: 'Autor',
                hintText: 'z. B. Carlos Ruiz Zafón',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 16),

            // ISBN mit Barcode-Scanner
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _isbnController,
                    decoration: InputDecoration(
                      labelText: 'ISBN',
                      hintText: '978-3-16-148410-0',
                      border: const OutlineInputBorder(),
                      helperText: 'Barcode scannen oder manuell eingeben',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.qr_code_scanner),
                        onPressed: _scanBarcode,
                        tooltip: 'Barcode scannen',
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: ElevatedButton.icon(
                    onPressed: _lookupIsbn,
                    icon: const Icon(Icons.search, size: 20),
                    label: const Text('Laden'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ],
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
                hintText: 'z. B. Spannender Mystery-Roman',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Grobes Start-Rating',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        // Checkbox zum Überspringen
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: _skipInitialRating,
                              onChanged: (value) {
                                setState(() => _skipInitialRating = value ?? false);
                              },
                            ),
                            const Text('Überspringen'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _skipInitialRating
                          ? 'Das Buch wird durch zufällige Paarvergleiche einsortiert'
                          : 'Wird durch Paarvergleiche verfeinert',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    if (!_skipInitialRating) ...[
                      const SizedBox(height: 16),
                      // Text Field für direkte Eingabe
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _ratingController,
                              decoration: const InputDecoration(
                                labelText: 'Rating (0-10)',
                                border: OutlineInputBorder(),
                                helperText: 'Oder nutze den Slider unten',
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (value) {
                                final parsed = double.tryParse(value);
                                if (parsed != null && parsed >= 0 && parsed <= 10) {
                                  setState(() => _rating = parsed);
                                }
                              },
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Bitte Rating eingeben';
                                }
                                final parsed = double.tryParse(value);
                                if (parsed == null) {
                                  return 'Ungültige Zahl';
                                }
                                if (parsed < 0 || parsed > 10) {
                                  return 'Rating muss zwischen 0 und 10 liegen';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Rating Anzeige
                          SizedBox(
                            width: 60,
                            child: Column(
                              children: [
                                Text(
                                  _rating.toStringAsFixed(1),
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: _getRatingColor(_rating),
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Slider
                      Slider(
                        value: _rating,
                        min: 0.0,
                        max: 10.0,
                        divisions: 100,
                        label: _rating.toStringAsFixed(1),
                        onChanged: (value) {
                          setState(() {
                            _rating = value;
                            _ratingController.text = value.toStringAsFixed(1);
                          });
                        },
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
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Submit-Button
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Weiter zum Vergleich'),
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

/// Screen für Barcode-Scanner
class _BarcodeScannerScreen extends StatefulWidget {
  const _BarcodeScannerScreen();

  @override
  State<_BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<_BarcodeScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _scanned = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode scannen'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
            tooltip: 'Taschenlampe',
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (_scanned) return;

              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isEmpty) return;

              final barcode = barcodes.first;
              final String? code = barcode.rawValue;

              if (code != null && code.isNotEmpty) {
                setState(() => _scanned = true);
                Navigator.pop(context, code);
              }
            },
          ),
          // Overlay mit Hinweis
          Center(
            child: Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  'Halte den Barcode in den Rahmen',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
