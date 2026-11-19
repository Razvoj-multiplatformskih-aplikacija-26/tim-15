abstract final class Endpoints {
  static String health() => '/api/health';

  static String login() => '/api/auth/login';
  static String logout() => '/api/auth/logout';
  static String me() => '/api/auth/me';

  static String games() => '/api/games';
  static String game(int id) => '/api/games/$id';
  static String board(int gameId) => '/api/games/$gameId/board';
  static String leaderboard(int gameId) => '/api/games/$gameId/leaderboard';

  static String scores() => '/api/scores';
  static String myScores() => '/api/scores/me';
  static String score(int id) => '/api/scores/$id';
  static String submit(int gameId) => '/api/games/$gameId/scores';
  static String withdraw(int id) => '/api/scores/$id/withdraw';
  static String approve(int id) => '/api/scores/$id/approve';
  static String reject(int id) => '/api/scores/$id/reject';
}
