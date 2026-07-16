import 'dart:io';
import 'package:flutter/material.dart';
import '../models/book.dart';

/// Widget zur Anzeige eines Buchcovers
/// Zeigt entweder das gespeicherte Cover oder einen Placeholder
class BookCover extends StatelessWidget {
  final Book book;
  final double width;
  final double height;
  final bool showPlaceholder;

  const BookCover({
    super.key,
    required this.book,
    this.width = 60,
    this.height = 90,
    this.showPlaceholder = true,
  });

  @override
  Widget build(BuildContext context) {
    // Hat das Buch ein Cover?
    if (book.coverUrl != null && book.coverUrl!.isNotEmpty) {
      final file = File(book.coverUrl!);

      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.file(
          file,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fehler beim Laden: Zeige Placeholder
            return _buildPlaceholder(context);
          },
        ),
      );
    }

    // Kein Cover: Placeholder
    return showPlaceholder ? _buildPlaceholder(context) : const SizedBox.shrink();
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book,
            size: width * 0.5,
            color: Theme.of(context).colorScheme.outline,
          ),
          if (width > 40 && book.isbn == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                'Kein Cover',
                style: TextStyle(
                  fontSize: 8,
                  color: Theme.of(context).colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
