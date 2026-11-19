import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:scoreboard_api/scoreboard_api.dart';
import 'package:scoreboard_api_client/scoreboard_api_client.dart';
import 'package:domain/domain.dart';
import 'package:test/test.dart';

const _baseUrl = 'http://server.test';

const _userJson = {
  'id': '1',
  'username': 'gost',
  'role': 'guest',
  'active': true,
};

late InMemoryTokenStore tokenStore;
late List<void Function()> unauthorizedCalls;
late void Function() onUnauthorized;

void main() {
  setUp(() {
    tokenStore = InMemoryTokenStore();
    unauthorizedCalls = [];
    onUnauthorized = () => unauthorizedCalls.add(() {});
  });

  ScoreboardApiClient buildClient(MockClient inner) =>
      ScoreboardApiClient(
        inner,
        baseUrl: Uri.parse(_baseUrl),
        tokenStore: tokenStore,
        onUnauthorized: onUnauthorized,
      );

  MockClient jsonClient(int status, Object? body) => MockClient(
        (request) async => http.Response(
          jsonEncode(body),
          status,
          headers: {'content-type': 'application/json'},
        ),
      );

  test('login stores the token and returns the user', () async {
    final client = buildClient(
      MockClient(
        (request) async => http.Response(
          jsonEncode({'token': 'abc123', 'user': _userJson}),
          200,
        ),
      ),
    );

    final response =
        await client.login(const LoginRequest(username: 'gost', password: 'x'));

    expect(response.token, 'abc123');
    expect(response.user.username, 'gost');
    expect(await tokenStore.readToken(), 'abc123');
  });

  test('invalid credentials map to AuthException', () async {
    final client = buildClient(
      jsonClient(
          401,
          const ApiError(
              code: ApiErrorCode.invalidCredentials,
              message: 'Wrong username or password.')
              .toJson()),
    );

    await expectLater(
      client.login(const LoginRequest(username: 'a', password: 'b')),
      throwsA(
        isA<AuthException>().having(
            (e) => e.message, 'message', 'Wrong username or password.'),
      ),
    );
  });

  test('expired session clears the token and notifies the app', () async {
    await tokenStore.writeToken('old-token');
    final client = buildClient(jsonClient(
        401,
        const ApiError(
                code: ApiErrorCode.unauthenticated,
                message: 'Session expired.')
            .toJson()));

    await expectLater(
      client.me(),
      throwsA(isA<SessionExpiredException>()),
    );

    expect(unauthorizedCalls, hasLength(1));
    expect(await tokenStore.readToken(), isNull);
  });

  test('forbidden maps to PermissionDeniedException', () async {
    await tokenStore.writeToken('t');
    final client = buildClient(jsonClient(
        403,
        const ApiError(
                code: ApiErrorCode.forbidden, message: 'Admins only.')
            .toJson()));

    await expectLater(
      client.allScores(),
      throwsA(isA<PermissionDeniedException>()),
    );
  });

  test('conflict maps to ConflictException', () async {
    await tokenStore.writeToken('t');
    final client = buildClient(
      jsonClient(
          409,
          const ApiError(
                  code: ApiErrorCode.conflict,
                  message: 'You already have a pending submission.')
              .toJson()),
    );

    await expectLater(
      client.submitScore(1, const SubmitScoreRequest(value: 10)),
      throwsA(isA<ConflictException>()),
    );
  });

  test('validation errors map to ValidationException', () async {
    await tokenStore.writeToken('t');
    final client = buildClient(
      jsonClient(
          422,
          const ApiError(
                  code: ApiErrorCode.overLimit,
                  message: 'The result cannot be bigger than 5.')
              .toJson()),
    );

    await expectLater(
      client.submitScore(1, const SubmitScoreRequest(value: 99)),
      throwsA(isA<ValidationException>()),
    );
  });

  test('network failures map to NetworkException', () async {
    final client = buildClient(
      MockClient((request) async => throw const SocketException('no server')),
    );

    await expectLater(
      client.games(),
      throwsA(
        isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Cannot reach the server. Please check your connection and try again.'),
      ),
    );
  });

  test('timeout maps to NetworkException', () async {
    final client = ScoreboardApiClient(
      MockClient((request) async {
        await Future<void>.delayed(const Duration(seconds: 5));
        return http.Response('ok', 200);
      }),
      baseUrl: Uri.parse(_baseUrl),
      tokenStore: tokenStore,
      timeout: const Duration(milliseconds: 20),
    );

    await expectLater(client.health(), throwsA(isA<NetworkException>()));
  });

  test('server repository maps dtos into domain objects', () async {
    final client = buildClient(
      MockClient(
        (request) async {
          if (request.url.path.endsWith('/board')) {
            return http.Response(
              jsonEncode(BoardDto(
                id: 3,
                limit: 5,
                game: GameDto(
                  id: 3,
                  name: 'CS2',
                  genre: 'Shooter',
                  releaseDate: DateTime.utc(2023),
                ),
              ).toJson()),
              200,
            );
          }
          return http.Response('[]', 200);
        },
      ),
    );
    await tokenStore.writeToken('t');
    final auth = ServerAuthRepository(client);
    final repository = ServerRepository(client, auth);

    final board = await repository.fetchBoard(3);

    expect(board.id, 3);
    expect(board.limit, 5);
    expect(board.game.name, 'CS2');
  });

  test('auth repository restores a valid session', () async {
    await tokenStore.writeToken('t');
    final client = buildClient(
      MockClient(
        (request) async =>
            http.Response(jsonEncode(_userJson), 200),
      ),
    );
    final auth = ServerAuthRepository(client);

    final user = await auth.getSession();

    expect(user, isA<User>());
    expect(user!.username, 'gost');
  });

  test('auth repository discards the session when the server rejects it',
      () async {
    await tokenStore.writeToken('stale');
    final client = buildClient(
      jsonClient(
          401,
          const ApiError(
                  code: ApiErrorCode.unauthenticated,
                  message: 'Session expired.')
              .toJson()),
    );
    final auth = ServerAuthRepository(client);

    expect(await auth.getSession(), isNull);
  });
}
