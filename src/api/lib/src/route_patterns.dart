abstract final class RoutePatterns {
  static const health = '/api/health';

  static const login = '/api/auth/login';
  static const logout = '/api/auth/logout';
  static const me = '/api/auth/me';

  static const games = '/api/games';
  static const game = '/api/games/:gameId';
  static const board = '/api/games/:gameId/board';
  static const leaderboard = '/api/games/:gameId/leaderboard';

  static const scores = '/api/scores';
  static const myScores = '/api/scores/me';
  static const score = '/api/scores/:scoreId';
  static const submit = '/api/games/:gameId/scores';
  static const withdraw = '/api/scores/:scoreId/withdraw';
  static const approve = '/api/scores/:scoreId/approve';
  static const reject = '/api/scores/:scoreId/reject';
}
