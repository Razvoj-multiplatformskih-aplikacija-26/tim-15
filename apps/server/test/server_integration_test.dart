import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:relic/relic.dart';
import 'package:server/server.dart';
import 'package:serverpod_embedded_postgres/serverpod_embedded_postgres.dart';
import 'package:test/test.dart';

void main() {
  late EmbeddedPostgres postgres;
  late Database database;
  late RelicServer server;
  late HttpClient client;
  late int port;
  late String guestToken;
  late String adminToken;
  late int tetrisId;
  late int cs2Id;

  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Object? body,
    String? token,
  }) async {
    final request = await client.openUrl(
      method,
      Uri.parse('http://127.0.0.1:$port$path'),
    );
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    if (token != null) {
      request.headers
          .set(HttpHeaders.authorizationHeader, 'Bearer $token');
    }
    if (body != null) request.write(jsonEncode(body));
    final response = await request.close();
    final text = await response.transform(const Utf8Decoder()).join();
    return {
      'status': response.statusCode,
      'body': text.isEmpty ? null : jsonDecode(text),
    };
  }

  Future<String> login(String username, {String? password}) async {
    final response = await request(
      'POST',
      '/api/auth/login',
      body: {
        'username': username,
        'password': password ?? '${username}123',
      },
    );
    expect(
      response['status'],
      200,
      reason: 'login failed: ${response['body']}',
    );
    final body = response['body'] as Map<String, dynamic>;
    expect(body['user']['username'], username);
    return body['token'] as String;
  }

  Map<String, dynamic> errorOf(Map<String, dynamic> response) =>
      response['body'] as Map<String, dynamic>;

  Future<Map<String, dynamic>> myPendingScore(String token) async {
    final mine = await request('GET', '/api/scores/me', token: token);
    final scores = mine['body'] as List<dynamic>;
    final pending = scores
        .where((score) => (score as Map<String, dynamic>)['state'] == 'pending')
        .toList();
    expect(pending, hasLength(1),
      reason: 'expected a single pending submission, got $pending');
    return pending.first as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> myApprovedScore(String token) async {
    final mine = await request('GET', '/api/scores/me', token: token);
    final scores = mine['body'] as List<dynamic>;
    final approved = scores
        .where((score) => (score as Map<String, dynamic>)['state'] == 'approved')
        .toList();
    expect(approved, isNotEmpty);
    return (approved.first as Map<String, dynamic>)
        .cast<String, dynamic>();
  }

  setUpAll(() async {
    final dataDir = Directory.systemTemp.createTempSync('scoreboard_pg_');
    postgres = await EmbeddedPostgres.start(
      EmbeddedPostgresOptions(
        dataDir: dataDir,
        databaseName: 'scoreboard_test',
        transport: const TcpTransport(),
      ),
    );
    database = await Database.open(
        '${postgres.connectionString.split('?').first}?sslmode=disable',
    );
    await runMigrations(database);
    await seedIfEmpty(database);
    final app = createApp(database, const Config(databaseUrl: 'unused'));
    server = await app.serve(port: 0);
    port = server.port;
    client = HttpClient();
    guestToken = await login('gost');
    adminToken = await login('admin');
    final gamesList =
        ((await request('GET', '/api/games', token: guestToken))['body']
                as List<dynamic>)
            .cast<Map<String, dynamic>>();
    tetrisId =
        gamesList.firstWhere((game) => game['name'] == 'Tetris')['id'] as int;
    cs2Id = gamesList.firstWhere(
            (game) => game['name'] == 'CS2 Aim Trainer')
        ['id'] as int;
    final mine = (await request('GET', '/api/scores/me', token: guestToken))[
        'body'] as List<dynamic>;
    for (final score in mine) {
      final submission = score as Map<String, dynamic>;
      if (submission['state'] != 'pending') continue;
      final game =
          (submission['board'] as Map<String, dynamic>)['game']
              as Map<String, dynamic>;
      if (game['name'] == 'Tetris') {
        final reject = await request(
          'POST',
          '/api/scores/${submission['id']}/reject',
          token: adminToken,
        );
        expect(reject['status'], 204, reason: '${reject['body']}');
      } else {
        final withdraw = await request(
          'POST',
          '/api/scores/${submission['id']}/withdraw',
          token: guestToken,
        );
        expect(withdraw['status'], 204, reason: '${withdraw['body']}');
      }
    }
  });

  tearDownAll(() async {
    client.close(force: true);
    await server.close(force: true);
    await database.close();
    await postgres.stop();
  });

  test('health endpoint responds', () async {
    final response = await request('GET', '/api/health');
    expect(response['status'], 200);
    expect(response['body'], {'status': 'ok'});
  });

  test('requests without a session are rejected', () async {
    final response = await request('GET', '/api/games');
    expect(response['status'], 401);
    expect(errorOf(response)['code'], 'unauthenticated');
  });

  test('login rejects invalid credentials', () async {
    final response = await request(
      'POST',
      '/api/auth/login',
      body: {'username': 'gost', 'password': 'wrong'},
    );
    expect(response['status'], 401);
    expect(errorOf(response)['code'], 'invalid_credentials');
  });

  test('login validates the request body', () async {
    final response = await request(
      'POST',
      '/api/auth/login',
      body: {'username': '', 'password': 'x'},
    );
    expect(response['status'], 422);
    expect(errorOf(response)['code'], 'validation_failed');
  });

  test('me returns the signed in user', () async {
    final response = await request('GET', '/api/auth/me', token: guestToken);
    expect(response['status'], 200);
    final user = response['body'] as Map<String, dynamic>;
    expect(user['username'], 'gost');
    expect(user['role'], 'guest');
  });

  test('games lists the seeded games', () async {
    final response = await request('GET', '/api/games', token: guestToken);
    expect(response['status'], 200);
    final games = response['body'] as List<dynamic>;
    expect(games.length, 4);
    final names = games
        .map((game) => (game as Map<String, dynamic>)['name'])
        .toSet();
    expect(names, containsAll(['Tetris', 'Chess']));
  });

  test('board returns the game limit', () async {
    final response = await request(
      'GET',
      '/api/games/$tetrisId/board',
      token: guestToken,
    );
    expect(response['status'], 200);
    final board = response['body'] as Map<String, dynamic>;
    expect(board['limit'], 10000);
    expect(board['game']['name'], 'Tetris');
  });

  test('leaderboard lists approved entries in descending order', () async {
    final response = await request(
      'GET',
      '/api/games/$tetrisId/leaderboard',
      token: guestToken,
    );
    expect(response['status'], 200);
    final entries = response['body'] as List<dynamic>;
    expect(entries, isNotEmpty);
    final values = entries
        .map((entry) => (entry as Map<String, dynamic>)['value'] as int)
        .toList();
    expect(values.length, greaterThan(0));
    for (final entry in entries) {
      expect((entry as Map<String, dynamic>)['state'], 'approved');
    }
    final sorted = List<int>.from(values)..sort((a, b) => b.compareTo(a));
    expect(values, sorted);
  });

  test('submit creates a pending score', () async {
    final response = await request(
      'POST',
      '/api/games/$tetrisId/scores',
      body: {'value': 1234},
      token: guestToken,
    );
    expect(response['status'], 201, reason: '${response['body']}');
    final score = response['body'] as Map<String, dynamic>;
    expect(score['value'], 1234);
    expect(score['state'], 'pending');
    expect(score['user']['username'], 'gost');
  });

  test('submit rejects invalid values', () async {
    final filipToken = await login('filip');
    final negative = await request(
      'POST',
      '/api/games/$tetrisId/scores',
      body: {'value': -1},
      token: filipToken,
    );
    expect(negative['status'], 422);
    expect(errorOf(negative)['code'], 'validation_failed');

    final missing = await request(
      'POST',
      '/api/games/$tetrisId/scores',
      body: {},
      token: filipToken,
    );
    expect(missing['status'], 422);
    expect(errorOf(missing)['code'], 'validation_failed');
  });

  test('submit enforces the board capacity', () async {
    final fillers = <(String, int)>[
      ('megi', 5),
      ('lena', 4),
      ('masa', 3),
      ('anja', 2),
      ('djordje', 1),
    ];
    for (final (username, value) in fillers) {
      final token = await login(username);
      final response = await request(
        'POST',
        '/api/games/$cs2Id/scores',
        body: {'value': value},
        token: token,
      );
      expect(response['status'], 201,
          reason: '$username: ${response['body']}');
      final scoreId = (response['body'] as Map<String, dynamic>)['id'];
      final approve = await request(
        'POST',
        '/api/scores/$scoreId/approve',
        token: adminToken,
      );
      expect(approve['status'], 204, reason: '${approve['body']}');
    }

    final ivanaToken = await login('ivana');
    final response = await request(
      'POST',
      '/api/games/$cs2Id/scores',
      body: {'value': 0},
      token: ivanaToken,
    );
    expect(response['status'], 409);
    expect(errorOf(response)['code'], 'conflict');
  });

  test('a second pending submission on the same board conflicts', () async {
    final response = await request(
      'POST',
      '/api/games/$tetrisId/scores',
      body: {'value': 100},
      token: guestToken,
    );
    expect(response['status'], 409);
    expect(errorOf(response)['code'], 'conflict');
  });

  test('my scores only contains my submissions', () async {
    final response = await request(
      'GET',
      '/api/scores/me',
      token: guestToken,
    );
    expect(response['status'], 200);
    final scores = response['body'] as List<dynamic>;
    expect(scores, isNotEmpty);
    for (final score in scores) {
      expect((score as Map<String, dynamic>)['user']['username'], 'gost');
    }
  });

  test('guests cannot approve', () async {
    final response = await request(
      'POST',
      '/api/scores/1/approve',
      token: guestToken,
    );
    expect(response['status'], 403);
    expect(errorOf(response)['code'], 'forbidden');
  });

  test('all scores requires admin', () async {
    final asGuest = await request('GET', '/api/scores', token: guestToken);
    expect(asGuest['status'], 403);
    final asAdmin = await request('GET', '/api/scores', token: adminToken);
    expect(asAdmin['status'], 200);
    expect(asAdmin['body'], isA<List<dynamic>>());
  });

  test('admin approves the pending submission', () async {
    final pending = await myPendingScore(guestToken);
    final pendingId = pending['id'] as int;

    final approve = await request(
      'POST',
      '/api/scores/$pendingId/approve',
      token: adminToken,
    );
    expect(approve['status'], 204);

    final score = await request(
      'GET',
      '/api/scores/$pendingId',
      token: guestToken,
    );
    expect((score['body'] as Map<String, dynamic>)['state'], 'approved');

    final doubleApprove = await request(
      'POST',
      '/api/scores/$pendingId/approve',
      token: adminToken,
    );
    expect(doubleApprove['status'], 409);
  });

  test('other users cannot withdraw my score', () async {
    final approved = await myApprovedScore(guestToken);
    final other = await login('tara');
    final response = await request(
      'POST',
      '/api/scores/${approved['id']}/withdraw',
      token: other,
    );
    expect(response['status'], 403);
    expect(errorOf(response)['code'], 'forbidden');
  });

  test('owner can withdraw an approved score', () async {
    final approved = await myApprovedScore(guestToken);
    final response = await request(
      'POST',
      '/api/scores/${approved['id']}/withdraw',
      token: guestToken,
    );
    expect(response['status'], 204);
    final score = await request(
      'GET',
      '/api/scores/${approved['id']}',
      token: guestToken,
    );
    expect((score['body'] as Map<String, dynamic>)['state'], 'archived');
  });

  test('logout invalidates the session', () async {
    final token = await login('tara');
    final before = await request('GET', '/api/auth/me', token: token);
    expect(before['status'], 200);
    final logout = await request('POST', '/api/auth/logout', token: token);
    expect(logout['status'], 204);
    final after = await request('GET', '/api/auth/me', token: token);
    expect(after['status'], 401);
  });

  test('unknown routes return 404', () async {
    final response = await request('GET', '/api/nope', token: guestToken);
    expect(response['status'], 404);
    expect(errorOf(response)['code'], 'not_found');
  });
}
