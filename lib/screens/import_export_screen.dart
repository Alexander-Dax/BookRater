import 'package:flutter/material.dart';
import '../services/csv_service.dart';
import '../services/language_service.dart';

/// Screen für Import und Export von Büchern
/// Unterstützt CSV-Export/Import und Goodreads-Import (Platzhalter)
class ImportExportScreen extends StatefulWidget {
  final LanguageService languageService;

  const ImportExportScreen({super.key, required this.languageService});

  @override
  State<ImportExportScreen> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends State<ImportExportScreen> {
  final CsvService _csvService = CsvService.instance;
  bool _isProcessing = false;

  String t(String key) => widget.languageService.t(key);

  /// Exportiert alle Bücher als CSV
  Future<void> _exportCSV() async {
    setState(() => _isProcessing = true);

    final filePath = await _csvService.exportToCSV();

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (filePath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${t('books_exported')}\n$filePath'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('export_failed')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Importiert Bücher aus einer CSV-Datei
  Future<void> _importCSV() async {
    setState(() => _isProcessing = true);

    final result = await _csvService.importFromCSV();

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Platzhalter für Goodreads-Import
  Future<void> _importGoodreads() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Goodreads Import'),
        content: const Text(
          'Diese Funktion ist noch nicht implementiert.\n\n'
          'Zukünftig können Sie hier Ihre Goodreads-Bücherliste '
          'direkt importieren.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t('understood')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import & Export'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header
                Text(
                  'Daten verwalten',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Exportieren oder importieren Sie Ihre Bücherliste',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 32),

                // CSV Export/Import Section
                _buildSection(
                  title: 'CSV Export & Import',
                  icon: Icons.description,
                  description:
                      'Exportieren Sie Ihre Bücher als CSV-Datei oder importieren Sie eine CSV-Datei.',
                  children: [
                    // Export Button
                    ListTile(
                      leading: const Icon(Icons.file_download),
                      title: Text(t('csv_export')),
                      subtitle: const Text('Alle Bücher als CSV exportieren'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _exportCSV,
                    ),
                    const Divider(),
                    // Import Button
                    ListTile(
                      leading: const Icon(Icons.file_upload),
                      title: Text(t('csv_import')),
                      subtitle: const Text('CSV-Datei importieren'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _importCSV,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Goodreads Import Section (Platzhalter)
                _buildSection(
                  title: 'Goodreads Import',
                  icon: Icons.import_contacts,
                  description:
                      'Importieren Sie Ihre Bücherliste direkt von Goodreads.',
                  isComingSoon: true,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.cloud_download),
                      title: const Text('Von Goodreads importieren'),
                      subtitle: const Text('Noch nicht verfügbar'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'BALD',
                              style: TextStyle(
                                color: Colors.orange[900],
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                      onTap: _importGoodreads,
                      enabled: false,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Info Card
                Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CSV Format',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Das CSV-Format enthält: Titel, Autor, ISBN, Jahr gelesen, Rating, Notizen',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blue[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  /// Baut eine Sektion mit Titel, Icon und Inhalt
  Widget _buildSection({
    required String title,
    required IconData icon,
    required String description,
    required List<Widget> children,
    bool isComingSoon = false,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                if (isComingSoon)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'COMING SOON',
                      style: TextStyle(
                        color: Colors.orange[900],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Section Content
            ...children,
          ],
        ),
      ),
    );
  }
}
