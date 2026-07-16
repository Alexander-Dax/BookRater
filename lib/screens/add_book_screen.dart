import 'package:flutter/material.dart';
import '../models/book.dart';

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
  final _wortzahlController = TextEditingController();
  final _jahrController = TextEditingController();
  final _metaController = TextEditingController();

  double _rating = 6.0;

  @override
  void initState() {
    super.initState();
    // Standard: Aktuelles Jahr
    _jahrController.text = DateTime.now().year.toString();
  }

  @override
  void dispose() {
    _titelController.dispose();
    _autorController.dispose();
    _isbnController.dispose();
    _wortzahlController.dispose();
    _jahrController.dispose();
    _metaController.dispose();
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
      wortzahl: _parseIntOrNull(_wortzahlController.text),
      jahrGelesen: _parseIntOrNull(_jahrController.text),
      meta: _metaController.text.trim().isEmpty ? null : _metaController.text.trim(),
      rating: _rating,
    );

    // Zurück zum HomeScreen mit dem Buch
    Navigator.pop(context, book);
  }

  int? _parseIntOrNull(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
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

            // ISBN
            TextFormField(
              controller: _isbnController,
              decoration: const InputDecoration(
                labelText: 'ISBN',
                hintText: '978-3-16-148410-0',
                border: OutlineInputBorder(),
                helperText: 'Optional: Für automatisches Cover-Download',
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16),

            // Jahr gelesen und Wortzahl (nebeneinander)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _jahrController,
                    decoration: const InputDecoration(
                      labelText: 'Jahr gelesen',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _wortzahlController,
                    decoration: const InputDecoration(
                      labelText: 'Wortzahl',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
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
                    Text(
                      'Grobes Start-Rating',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Wird durch Paarvergleiche verfeinert',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
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
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
