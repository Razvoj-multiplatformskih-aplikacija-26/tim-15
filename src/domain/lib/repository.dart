import 'package:domain/board.dart';
import 'package:domain/game.dart';
import 'package:domain/user.dart';

abstract class Repository {
  Future<List<Game>> fetchGames();

  Future<Game> fetchGame(int id);

  Future<Board> fetchBoard(int gameId);

  Future<List<Score>> fetchLeaderboard(int gameId);

  Future<Score?> fetchScore(int id);

  Future<List<Score>> fetchMyScores();

  Future<Score> submitScore(int gameId, int value);

  Future<void> withdrawScore(int id);

  Future<void> approveScore(int id);

  User get currentUser;
}
