import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/media_type.dart';
import '../services/mal_service.dart';
import '../services/language_service.dart';

/// Screen zum Hinzufügen einer neuen Manga-Serie
/// Ermöglicht Suche über MyAnimeList und manuelle Eingabe
class AddMangaScreen extends StatefulWidget {
  final LanguageService languageService;

  const AddMangaScreen({super.key, required this.languageService});

  @override
  State<AddMangaScreen> createState() => _AddMangaScreenState();
}

class _AddMangaScreenState extends State<AddMangaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _titelController = TextEditingController();
  final _autorController = TextEditingController();
  final _jahrController = TextEditingController();
  final _metaController = TextEditingController();

  String? _selectedMalId;
  String? _coverUrl;
  bool _isSearching = false;
  bool _skipInitialRating = false;
  double _rating = 6.0;
  List<MangaSearchResult> _searchResults = [];
  final MalService _malService = MalService.instance;
  late final TextEditingController _ratingController;

  String t(String key) => widget.languageService.t(key);

  @override
  void initState() {
    super.initState();
    _ratingController = TextEditingController(text: _rating.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _titelController.dispose();
    _autorController.dispose();
    _jahrController.dispose();
    _metaController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  /// Sucht nach Manga auf MyAnimeList
  Future<void> _searchManga() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchResults = [];
    });

    try {
      final results = await _malService.searchManga(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });

      // Zeige Feedback wenn keine Ergebnisse gefunden wurden
      if (results.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t('no_results'))),
        );
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('search_error'))),
      );
    }
  }

  /// Wählt einen Manga aus den Suchergebnissen aus
  void _selectManga(MangaSearchResult manga) {
    setState(() {
      _titelController.text = manga.bestTitle;
      _autorController.text = manga.primaryAuthor;
      _coverUrl = manga.imageUrl;
      _selectedMalId = manga.malId;

      // Optional: Synopsis in Meta-Feld
      if (manga.synopsis != null && _metaController.text.isEmpty) {
        _metaController.text = manga.synopsis!;
      }

      // Suchergebnisse ausblenden
      _searchResults = [];
      _searchController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${manga.bestTitle} ${t('manga_selected')}')),
    );
  }

  /// Speichert die Manga-Serie
  void _saveManga() {
    if (_formKey.currentState!.validate()) {
      final int? jahr = int.tryParse(_jahrController.text.trim());

      final manga = Book(
        titel: _titelController.text.trim(),
        autor: _autorController.text.trim().isNotEmpty
            ? _autorController.text.trim()
            : null,
        jahrGelesen: jahr,
        meta: _metaController.text.trim().isNotEmpty
            ? _metaController.text.trim()
            : null,
        rating: _skipInitialRating ? 5.0 : _rating,
        coverUrl: _coverUrl,
        mediaType: MediaType.manga,
        malId: _selectedMalId,
      );

      Navigator.pop(context, {'book': manga, 'skipRating': _skipInitialRating});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t('add_manga_screen_title')),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // MyAnimeList Suche
              _buildSearchSection(),

              const SizedBox(height: 24),

              // Suchergebnisse
              if (_isSearching) _buildLoadingIndicator(),
              if (_searchResults.isNotEmpty) _buildSearchResults(),

              const SizedBox(height: 24),

              // Eingabeformular
              _buildForm(),

              const SizedBox(height: 24),

              // Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t('mal_search'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              t('mal_search_hint'),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: t('manga_name'),
                      hintText: t('manga_name_example'),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _searchManga(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _isSearching ? null : _searchManga,
                  icon: const Icon(Icons.search),
                  label: Text(t('search')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              t('search_results'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final manga = _searchResults[index];
              return ListTile(
                leading: manga.imageUrl != null
                    ? Image.network(
                        manga.imageUrl!,
                        width: 40,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.auto_stories),
                      )
                    : const Icon(Icons.auto_stories),
                title: Text(manga.bestTitle),
                subtitle: Text(
                  '${manga.primaryAuthor}${manga.volumes != null ? ' • ${manga.volumes} ${t('volumes')}' : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: manga.score != null
                    ? Chip(
                        label: Text(
                          manga.score!.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12),
                        ),
                      )
                    : null,
                onTap: () => _selectManga(manga),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('details'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Titel
          TextFormField(
            controller: _titelController,
            decoration: InputDecoration(
              labelText: t('title_required'),
              border: const OutlineInputBorder(),
              hintText: t('manga_name_example'),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return t('title_required_error');
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Autor
          TextFormField(
            controller: _autorController,
            decoration: InputDecoration(
              labelText: t('author'),
              border: const OutlineInputBorder(),
              hintText: t('author_example'),
            ),
          ),
          const SizedBox(height: 16),

          // Jahr gelesen
          TextFormField(
            controller: _jahrController,
            decoration: InputDecoration(
              labelText: t('year_read'),
              border: const OutlineInputBorder(),
              hintText: t('year_example'),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          // Meta/Notizen
          TextFormField(
            controller: _metaController,
            decoration: InputDecoration(
              labelText: t('notes'),
              border: const OutlineInputBorder(),
              hintText: t('notes_hint'),
            ),
            maxLines: 3,
          ),

          // Cover-Vorschau
          if (_coverUrl != null) ...[
            const SizedBox(height: 16),
            Text(t('cover_preview')),
            const SizedBox(height: 8),
            Center(
              child: Image.network(
                _coverUrl!,
                height: 200,
                errorBuilder: (context, error, stackTrace) => Text(t('cover_load_error')),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Initial Rating Section
          Text(
            t('initial_rating'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Rating Input Field (0-10)
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _ratingController,
                  decoration: InputDecoration(
                    labelText: t('rating'),
                    hintText: '0.0 - 10.0',
                    border: const OutlineInputBorder(),
                    enabled: !_skipInitialRating,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  enabled: !_skipInitialRating,
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    if (parsed != null && parsed >= 0 && parsed <= 10) {
                      setState(() => _rating = parsed);
                    }
                  },
                  validator: (value) {
                    if (_skipInitialRating) return null;
                    if (value == null || value.isEmpty) {
                      return t('rating_required');
                    }
                    final parsed = double.tryParse(value);
                    if (parsed == null || parsed < 0 || parsed > 10) {
                      return t('rating_range_error');
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Text(
                _rating.toStringAsFixed(1),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Slider for Rating
          if (!_skipInitialRating)
            Slider(
              value: _rating,
              min: 0,
              max: 10,
              divisions: 100,
              label: _rating.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  _rating = value;
                  _ratingController.text = value.toStringAsFixed(1);
                });
              },
            ),

          const SizedBox(height: 16),

          // Optional rating checkbox
          CheckboxListTile(
            title: Text(t('skip_initial_rating')),
            subtitle: Text(t('skip_initial_rating_hint')),
            value: _skipInitialRating,
            onChanged: (value) {
              setState(() => _skipInitialRating = value ?? false);
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t('cancel')),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveManga,
            child: Text(t('continue_to_rating')),
          ),
        ),
      ],
    );
  }
}
