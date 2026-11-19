import 'dart:convert';

import 'package:backoffice/app.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:scoreboard_api_client/scoreboard_api_client.dart';

http.Response jsonResponse(Object body, [int status = 200]) => http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json'},
    );

MockClient mockServer() {
  return MockClient(
      (http.Request request, [http.Client? client]) async {
    if (request.method == 'GET' && request.url.path == '/api/auth/me') {
      return jsonResponse(
          {'id': '10', 'username': 'admin', 'role': 'admin', 'active': true});
    }
    if (request.method == 'GET' && request.url.path == '/api/games') {
      return jsonResponse([
        {'id': 1, 'name': 'Tetris', 'genre': 'Puzzle', 'date': '1984-01-01'},
      ]);
    }
    if (request.url.path == '/api/scores') {
      return jsonResponse([]);
    }
    return jsonResponse(
        {'code': 'not_found', 'message': 'Not found.'}, 404);
  });
}

void main() {
  testWidgets('Backoffice app starts and shows title',
      (WidgetTester tester) async {
    final store = InMemoryTokenStore();
    await store.writeToken('test-token');
    final server = mockServer();
    final client = ScoreboardApiClient(
      server,
      baseUrl: Uri.parse('http://server.test'),
      tokenStore: store,
    );
    final authRepository = ServerAuthRepository(client);
    final auth = AuthBloc(authRepository)..add(const AuthRestore());

    await tester.pumpWidget(
      BackofficeApp(
        auth: auth,
        repository: ServerRepository(client, authRepository),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('Scoreboard Backoffice'), findsOneWidget);
  });
}
