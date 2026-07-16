import 'package:flutter_test/flutter_test.dart';
import 'package:book_rater_app/main.dart';

void main() {
  testWidgets('App startet erfolgreich', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BookRaterApp());

    // Verify that the app title is shown
    expect(find.text('Buch-Ranking'), findsOneWidget);
  });
}
