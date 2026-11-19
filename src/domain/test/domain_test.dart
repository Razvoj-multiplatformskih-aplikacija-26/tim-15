import 'package:domain/domain.dart';
import 'package:test/test.dart';

class StubRepository implements Repository {
  @override
  Future<List<Game>> fetchGames() async => const [];

  @override
  Future<Game> fetchGame(int id) async => throw UnimplementedError();

  @override
  Future<Board> fetchBoard(int gameId) async => throw UnimplementedError();

  @override
  Future<List<Score>> fetchLeaderboard(int gameId) async =>
      throw UnimplementedError();

  @override
  Future<Score?> fetchScore(int id) async => throw UnimplementedError();

  @override
  Future<List<Score>> fetchMyScores() async => throw UnimplementedError();

  @override
  Future<List<Score>> fetchAllScores() async => throw UnimplementedError();

  @override
  Future<Score> submitScore(int gameId, int value) async =>
      throw UnimplementedError();

  @override
  Future<void> withdrawScore(int id) async => throw UnimplementedError();

  @override
  Future<void> approveScore(int id) async => throw UnimplementedError();

  @override
  Future<void> rejectScore(int id) async => throw UnimplementedError();

  @override
  User get currentUser => throw UnimplementedError();
}

class ScriptedAuthRepository implements AuthRepository {
  User? nextUser;
  String? nextError;
  bool loggedOut = false;

  @override
  Future<User> login(String username, String password) async {
    final error = nextError;
    if (error != null) throw AuthException(error);
    return nextUser ?? const User(id: '1', username: 'gost', role: Role.guest);
  }

  @override
  Future<void> logout() async {
    loggedOut = true;
  }

  @override
  Future<User?> getSession() async => nextUser;
}

void main() {
  Future<void> pump([int ticks = 20]) async {
    for (var i = 0; i < ticks; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  test('GamesBloc emits loading and loaded states', () async {
    final bloc = GamesBloc(StubRepository());
    expect(bloc.state, isA<GamesInitial>());
    final states = <GamesState>[];
    final subscription = bloc.stream.listen(states.add);
    bloc.add(const GamesLoad());
    await pump();
    await subscription.cancel();
    expect(states, [isA<GamesLoading>(), isA<GamesLoaded>()]);
    expect(bloc.state, isA<GamesLoaded>());
  });

  test('AuthBloc restores a stored session', () async {
    final repo = ScriptedAuthRepository()
      ..nextUser = const User(id: '1', username: 'gost', role: Role.guest);
    final bloc = AuthBloc(repo);
    final states = <AuthState>[];
    final subscription = bloc.stream.listen(states.add);
    bloc.add(const AuthRestore());
    await pump();
    await subscription.cancel();
    expect(states, [isA<AuthRestoring>(), isA<AuthLoggedIn>()]);
    expect((bloc.state as AuthLoggedIn).user.username, 'gost');
  });

  test('AuthBloc restores to logged out without a session', () async {
    final bloc = AuthBloc(ScriptedAuthRepository());
    final states = <AuthState>[];
    final subscription = bloc.stream.listen(states.add);
    bloc.add(const AuthRestore());
    await pump();
    await subscription.cancel();
    expect(states, [isA<AuthRestoring>(), isA<AuthLoggedOut>()]);
    expect(bloc.state, isA<AuthLoggedOut>());
  });

  test('AuthBloc logs in', () async {
    final repo = ScriptedAuthRepository()
      ..nextUser = const User(id: '7', username: 'Lena', role: Role.guest);
    final bloc = AuthBloc(repo);
    final states = <AuthState>[];
    final subscription = bloc.stream.listen(states.add);
    bloc.add(const AuthLogin(username: 'Lena', password: 'x'));
    await pump();
    await subscription.cancel();
    expect(states, [isA<AuthLoginLoading>(), isA<AuthLoggedIn>()]);
    expect((bloc.state as AuthLoggedIn).user.id, '7');
  });

  test('AuthBloc reports login failures from the server', () async {
    final repo = ScriptedAuthRepository()
      ..nextError = 'Wrong username or password.';
    final bloc = AuthBloc(repo);
    final states = <AuthState>[];
    final subscription = bloc.stream.listen(states.add);
    bloc.add(const AuthLogin(username: 'gost', password: 'wrong'));
    await pump();
    await subscription.cancel();
    expect(states, [isA<AuthLoginLoading>(), isA<AuthLoginError>()]);
    expect(
        (bloc.state as AuthLoginError).message, 'Wrong username or password.');
  });

  test('AuthBloc logs out', () async {
    final repo = ScriptedAuthRepository();
    final bloc = AuthBloc(repo);
    final states = <AuthState>[];
    final subscription = bloc.stream.listen(states.add);
    bloc.add(const AuthLogout());
    await pump();
    await subscription.cancel();
    expect(states, [isA<AuthLoggedOut>()]);
    expect(repo.loggedOut, isTrue);
  });

  group('rules', () {
    test('validateScoreValue rejects out of range values', () {
      expect(
          validateScoreValue(value: -1, maxScore: 100),
          'The result cannot be negative.');
      expect(
          validateScoreValue(value: 101, maxScore: 100),
          'The result cannot be bigger than 100.');
      expect(validateScoreValue(value: 50, maxScore: 100), isNull);
      expect(validateScoreValue(value: 0, maxScore: 100), isNull);
    });

    test('ranksInTopResults enforces board capacity', () {
      expect(
        ranksInTopResults(value: 100, rankedValues: [90, 80, 70], capacity: 3),
        isTrue,
      );
      expect(
        ranksInTopResults(value: 100, rankedValues: [50, 40, 30], capacity: 3),
        isTrue,
      );
      expect(
        ranksInTopResults(value: 20, rankedValues: [50, 40, 30], capacity: 3),
        isFalse,
      );
      expect(
        ranksInTopResults(value: 100, rankedValues: [50, 40], capacity: 3),
        isTrue,
      );
    });

    test('state transition guards', () {
      expect(canDecide(ScoreState.pending), isTrue);
      expect(canDecide(ScoreState.approved), isFalse);
      expect(canWithdraw(ScoreState.pending), isTrue);
      expect(canWithdraw(ScoreState.approved), isTrue);
      expect(canWithdraw(ScoreState.archived), isFalse);
      expect(canWithdraw(ScoreState.rejected), isFalse);
    });
  });
}
