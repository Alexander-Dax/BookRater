import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/database_service.dart';
import '../services/language_service.dart';
import '../utils/constants.dart';
import '../widgets/book_cover.dart';

/// Tier-List Visualisierung (S/A/B/C/D/F)
class TierListScreen extends StatefulWidget {
  final LanguageService languageService;

  const TierListScreen({super.key, required this.languageService});

  @override
  State<TierListScreen> createState() => _TierListScreenState();
}

class _TierListScreenState extends State<TierListScreen> {
  final DatabaseService _db = DatabaseService.instance;
  List<Book> _books = [];
  bool _isLoading = true;

  // Gruppierte Bücher nach Tiers
  final Map<String, List<Book>> _tierBooks = {};

  String t(String key) => widget.languageService.t(key);

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);

    final books = await _db.getAllBooks();

    // Gruppiere Bücher nach Tiers
    _tierBooks.clear();
    for (final tier in tiers) {
      _tierBooks[tier.name] = [];
    }

    for (final book in books) {
      final tierName = _getTierForRating(book.rating);
      _tierBooks[tierName]?.add(book);
    }

    setState(() {
      _books = books;
      _isLoading = false;
    });
  }

  String _getTierForRating(double rating) {
    for (final tier in tiers) {
      if (rating >= tier.minRating && rating <= tier.maxRating) {
        return tier.name;
      }
    }
    return 'F'; // Fallback
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t('tierlist')),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showTierInfo,
            tooltip: t('tier_explanation'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _books.isEmpty
              ? _buildEmptyState()
              : _buildTierList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            t('no_books_yet'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierList() {
    return ListView(
      children: [
        // Header mit Statistik
        _buildStatisticsCard(),

        const SizedBox(height: 8),

        // Tier-Reihen
        for (final tier in tiers) _buildTierRow(tier),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStatisticsCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t('statistics'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(t('total'), _books.length.toString()),
                if (_books.isNotEmpty)
                  _buildStatItem(
                    t('average_rating'),
                    _calculateAverage().toStringAsFixed(2),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  double _calculateAverage() {
    if (_books.isEmpty) return 0.0;
    final sum = _books.fold<double>(0, (sum, book) => sum + book.rating);
    return sum / _books.length;
  }

  Widget _buildTierRow(TierConfig tier) {
    final books = _tierBooks[tier.name] ?? [];
    final tierColor = Color(tier.color);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tier-Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: tierColor.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                // Tier-Label
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: tierColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      tier.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Tier-Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTierDescription(tier.name),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${tier.minRating.toStringAsFixed(1)} - ${tier.maxRating.toStringAsFixed(1)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Anzahl
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: tierColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${books.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bücher (horizontal scrollbar)
          if (books.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  t('no_books_in_tier'),
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            )
          else
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(12),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  return _buildBookCard(books[index], tierColor);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBookCard(Book book, Color tierColor) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: () => _showBookDetails(book),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover (oben)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: BookCover(
                  book: book,
                  width: 140,
                  height: 100,
                ),
              ),
              // Info (unten)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Rating-Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: tierColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          book.rating.toStringAsFixed(2),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Titel
                      Text(
                        book.titel,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Autor
                      if (book.autor != null && book.autor!.isNotEmpty)
                        Text(
                          book.autor!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTierDescription(String tierName) {
    switch (tierName) {
      case 'S':
        return t('tier_s');
      case 'A':
        return t('tier_a');
      case 'B':
        return t('tier_b');
      case 'C':
        return t('tier_c');
      case 'D':
        return t('tier_d');
      case 'F':
        return t('tier_f');
      default:
        return '';
    }
  }

  void _showBookDetails(Book book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(book.titel),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (book.autor != null && book.autor!.isNotEmpty)
              _detailRow(t('author'), book.autor!),
            _detailRow(t('rating'), book.rating.toStringAsFixed(2)),
            _detailRow(t('tier'), _getTierForRating(book.rating)),
            if (book.jahrGelesen != null)
              _detailRow(t('year_read'), book.jahrGelesen.toString()),
            if (book.meta != null && book.meta!.isNotEmpty)
              _detailRow(t('notes'), book.meta!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t('close')),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showTierInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('tier_system')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('tier_intro'),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              for (final tier in tiers) ...[
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(tier.color),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          tier.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getTierDescription(tier.name),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${tier.minRating.toStringAsFixed(1)} - ${tier.maxRating.toStringAsFixed(1)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
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
}
