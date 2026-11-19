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

  Future<List<Score>> fetchAllScores();

  Future<Score> submitScore(int gameId, int value);

  Future<void> withdrawScore(int id);

  Future<void> approveScore(int id);

  Future<void> rejectScore(int id);

  User get currentUser;
}

abstract class AuthRepository {
  Future<User> login(String username, String password);

  Future<void> logout();

  Future<User?> getSession();
}
