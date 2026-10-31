import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

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
  Future<Score> submitScore(int gameId, int value) async =>
      throw UnimplementedError();

  @override
  Future<void> withdrawScore(int id) async => throw UnimplementedError();

  @override
  Future<void> approveScore(int id) async => throw UnimplementedError();

  @override
  User get currentUser => throw UnimplementedError();
}

void main() {
  test('GamesBloc emits loading and loaded states', () {
    final bloc = GamesBloc(StubRepository());

    expect(bloc.state, isA<GamesInitial>());
    expectLater(
      bloc.stream,
      emitsInOrder([isA<GamesLoading>(), isA<GamesLoaded>()]),
    );
    bloc.add(const GamesLoad());
  });
}
