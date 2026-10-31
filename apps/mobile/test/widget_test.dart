import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboard_system/app.dart';
import 'package:scoreboard_system/data/fake_repository.dart';

void main() {
  testWidgets('App renders games screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ScoreboardApp(repository: FakeRepository()),
    );
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    expect(find.text('Scoreboard'), findsOneWidget);
  });
}
