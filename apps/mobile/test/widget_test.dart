import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboard_system/app.dart';

void main() {
  testWidgets('App renders games screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ScoreboardApp());
    await tester.pumpAndSettle();

    expect(find.text('Scoreboard'), findsOneWidget);
  });
}