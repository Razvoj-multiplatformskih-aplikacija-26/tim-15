import 'package:domain/domain.dart';
import 'package:scoreboard_api/scoreboard_api.dart';

import 'api_client.dart';
import 'mappers.dart';
import 'server_auth_repository.dart';

final class ServerRepository implements Repository {
  ServerRepository(this._client, this._auth);

  final ScoreboardApiClient _client;
  final ServerAuthRepository _auth;

  @override
  User get currentUser {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Not signed in.');
    return user;
  }

  @override
  Future<List<Game>> fetchGames() async =>
      (await _client.games()).map(toDomainGame).toList();

  @override
  Future<Game> fetchGame(int id) async => toDomainGame(await _client.game(id));

  @override
  Future<Board> fetchBoard(int gameId) async =>
      toDomainBoard(await _client.board(gameId));

  @override
  Future<List<Score>> fetchLeaderboard(int gameId) async =>
      (await _client.leaderboard(gameId)).map(toDomainScore).toList();

  @override
  Future<Score?> fetchScore(int id) async {
    final dto = await _client.score(id);
    return dto == null ? null : toDomainScore(dto);
  }

  @override
  Future<List<Score>> fetchMyScores() async =>
      (await _client.myScores()).map(toDomainScore).toList();

  @override
  Future<List<Score>> fetchAllScores() async =>
      (await _client.allScores()).map(toDomainScore).toList();

  @override
  Future<Score> submitScore(int gameId, int value) async => toDomainScore(
        await _client.submitScore(gameId, SubmitScoreRequest(value: value)),
      );

  @override
  Future<void> withdrawScore(int id) => _client.withdrawScore(id);

  @override
  Future<void> approveScore(int id) => _client.approveScore(id);

  @override
  Future<void> rejectScore(int id) => _client.rejectScore(id);
}
