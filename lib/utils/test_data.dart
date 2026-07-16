import '../models/book.dart';
import '../services/database_service.dart';

/// Hilfsfunktion zum Hinzufügen von Test-Daten
/// Nur für die Entwicklung - später entfernen!
Future<void> addTestBooks() async {
  final db = DatabaseService.instance;

  // Prüfen ob schon Bücher existieren
  final count = await db.getBookCount();
  if (count > 0) {
    print('Datenbank enthält bereits $count Bücher. Keine Test-Daten hinzugefügt.');
    return;
  }

  final testBooks = [
    Book(
      titel: 'Der Herr der Ringe',
      autor: 'J.R.R. Tolkien',
      wortzahl: 481000,
      jahrGelesen: 2023,
      rating: 9.5,
      meta: 'Episches Fantasy-Meisterwerk',
    ),
    Book(
      titel: '1984',
      autor: 'George Orwell',
      wortzahl: 88000,
      jahrGelesen: 2024,
      rating: 8.8,
      meta: 'Dystopischer Klassiker',
    ),
    Book(
      titel: 'Harry Potter und der Stein der Weisen',
      autor: 'J.K. Rowling',
      wortzahl: 77000,
      jahrGelesen: 2022,
      rating: 8.2,
    ),
    Book(
      titel: 'Die Verwandlung',
      autor: 'Franz Kafka',
      wortzahl: 22000,
      jahrGelesen: 2023,
      rating: 7.5,
      meta: 'Surreal und bedrückend',
    ),
    Book(
      titel: 'Der kleine Prinz',
      autor: 'Antoine de Saint-Exupéry',
      wortzahl: 16000,
      jahrGelesen: 2021,
      rating: 8.0,
    ),
    Book(
      titel: 'Faust',
      autor: 'Johann Wolfgang von Goethe',
      wortzahl: 60000,
      jahrGelesen: 2020,
      rating: 6.5,
      meta: 'Klassiker, aber schwer zu lesen',
    ),
    Book(
      titel: 'Die Leiden des jungen Werther',
      autor: 'Johann Wolfgang von Goethe',
      wortzahl: 35000,
      jahrGelesen: 2019,
      rating: 5.8,
    ),
    Book(
      titel: 'Das Parfum',
      autor: 'Patrick Süskind',
      wortzahl: 93000,
      jahrGelesen: 2024,
      rating: 7.8,
      meta: 'Düster und faszinierend',
    ),
  ];

  for (final book in testBooks) {
    await db.insertBook(book);
  }

  print('${testBooks.length} Test-Bücher hinzugefügt!');
}
