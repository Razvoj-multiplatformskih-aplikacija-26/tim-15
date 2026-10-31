import 'package:domain/domain.dart';

final class FakeRepository implements Repository {
  FakeRepository() {
    _boards
      ..add(Board(id: 1, limit: 10000, game: _games[0]))
      ..add(Board(id: 2, limit: 10000, game: _games[1]))
      ..add(Board(id: 3, limit: 5, game: _games[2]))
      ..add(Board(id: 4, limit: 100, game: _games[3]));
    _populateFakeData();
  }

  static const _loadDelay = Duration(milliseconds: 800);

  final List<User> _users = [
    User(id: 'u-1', username: 'gost', role: Role.guest),
    User(id: 'u-2', username: 'Megi', role: Role.guest),
    User(id: 'u-3', username: 'Lena', role: Role.guest),
    User(id: 'u-4', username: 'Masa', role: Role.guest),
    User(id: 'u-5', username: 'Anja', role: Role.guest),
    User(id: 'u-6', username: 'Djordje', role: Role.guest),
    User(id: 'u-7', username: 'Ivana', role: Role.guest),
    User(id: 'u-8', username: 'Tara', role: Role.guest),
    User(id: 'u-9', username: 'Filip', role: Role.guest),
  ];

  final List<Game> _games = [
    Game(id: 1, name: 'Tetris', genre: 'Puzzle', releaseDate: DateTime(1984)),
    Game(id: 2, name: 'Minecraft Speedrun', genre: 'Sandbox', releaseDate: DateTime(2011)),
    Game(id: 3, name: 'CS2 Aim Trainer', genre: 'Shooter', releaseDate: DateTime(2023)),
    Game(id: 4, name: 'Chess', genre: 'Strategy', releaseDate: DateTime(1475)),
  ];

  final List<Board> _boards = [];

  @override
  User get currentUser => _users[0];

  Future<void> _simulateLoad() => Future.delayed(_loadDelay);

  Game _gameForId(int gameId) =>
      _games.firstWhere((game) => game.id == gameId);

  Board _boardForGame(int gameId) =>
      _boards.firstWhere((board) => board.game.id == gameId);

  Score? _findScore(int id) {
    for (final board in _boards) {
      for (final score in board.scores) {
        if (score.id == id) return score;
      }
    }
    return null;
  }

  Score _makeScore({
    required int id,
    required int scoreValue,
    required Board board,
    required User user,
    required ScoreState state,
    int daysAgo = 0,
  }) {
    final now = DateTime.now().subtract(Duration(days: daysAgo));
    final score = Score(
      id: id,
      name: 'Score $id',
      createdAt: now,
      lastModified: now,
      score: scoreValue,
      board: board,
      user: user,
    );
    score.state = state;
    return score;
  }

  void _populateFakeData() {
    _boards[0].scores.addAll([
      _makeScore(id: 1, scoreValue: 15000, board: _boards[0], user: _users[1], state: ScoreState.approved),
      _makeScore(id: 3, scoreValue: 18000, board: _boards[0], user: _users[2], state: ScoreState.approved),
      _makeScore(id: 4, scoreValue: 9000, board: _boards[0], user: _users[3], state: ScoreState.approved),
      _makeScore(id: 5, scoreValue: 4000, board: _boards[0], user: _users[4], state: ScoreState.approved),
      _makeScore(id: 6, scoreValue: 2000, board: _boards[0], user: _users[5], state: ScoreState.approved),
      _makeScore(id: 7, scoreValue: 13000, board: _boards[0], user: _users[6], state: ScoreState.approved),
      _makeScore(id: 8, scoreValue: 900, board: _boards[0], user: _users[7], state: ScoreState.approved),
      _makeScore(id: 9, scoreValue: 4600, board: _boards[0], user: _users[0], state: ScoreState.pending),
      _makeScore(id: 10, scoreValue: 1000, board: _boards[0], user: _users[2], state: ScoreState.rejected),
      _makeScore(id: 101, scoreValue: 12000, board: _boards[0], user: currentUser, state: ScoreState.approved, daysAgo: 5),
    ]);

    _boards[1].scores.addAll([
      _makeScore(id: 11, scoreValue: 300, board: _boards[1], user: _users[1], state: ScoreState.approved),
      _makeScore(id: 12, scoreValue: 250, board: _boards[1], user: _users[2], state: ScoreState.approved),
      _makeScore(id: 102, scoreValue: 400, board: _boards[1], user: currentUser, state: ScoreState.rejected, daysAgo: 2),
    ]);

    _boards[2].scores.addAll([
      _makeScore(id: 15, scoreValue: 950, board: _boards[2], user: _users[1], state: ScoreState.approved),
      _makeScore(id: 16, scoreValue: 700, board: _boards[2], user: _users[4], state: ScoreState.archived),
      _makeScore(id: 103, scoreValue: 800, board: _boards[2], user: currentUser, state: ScoreState.pending, daysAgo: 1),
    ]);
  }

  @override
  Future<List<Game>> fetchGames() async {
    await _simulateLoad();
    return List<Game>.from(_games);
  }

  @override
  Future<Game> fetchGame(int id) async {
    await _simulateLoad();
    return _gameForId(id);
  }

  @override
  Future<Board> fetchBoard(int gameId) async {
    await _simulateLoad();
    return _boardForGame(gameId);
  }

  @override
  Future<List<Score>> fetchLeaderboard(int gameId) async {
    await _simulateLoad();
    final scores = _boardForGame(gameId).scores
        .where((score) => score.state == ScoreState.approved)
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return scores;
  }

  @override
  Future<Score?> fetchScore(int id) async {
    await _simulateLoad();
    return _findScore(id);
  }

  @override
  Future<List<Score>> fetchMyScores() async {
    await _simulateLoad();
    final myScores = <Score>[];
    for (final board in _boards) {
      myScores.addAll(board.scores.where((score) => score.user.id == currentUser.id));
    }
    myScores.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return myScores;
  }

  @override
  Future<Score> submitScore(int gameId, int value) async {
    await _simulateLoad();
    final board = _boardForGame(gameId);
    final now = DateTime.now();
    final score = Score(
      id: now.microsecondsSinceEpoch,
      name: 'My Score',
      createdAt: now,
      lastModified: now,
      score: value,
      board: board,
      user: currentUser,
    );
    score.state = ScoreState.pending;
    currentUser.submitScore(score, board);
    return score;
  }

  @override
  Future<void> withdrawScore(int id) async {
    await _simulateLoad();
    final score = _findScore(id);
    if (score == null) {
      throw PermissionDeniedException('Score $id not found');
    }
    score.board.deleteScore(score);
  }

  @override
  Future<void> approveScore(int id) async {
    await _simulateLoad();
    final score = _findScore(id);
    if (score == null) {
      throw PermissionDeniedException('Score $id not found');
    }
    final userScores = score.board.scores
        .where((s) => s.user.id == score.user.id)
        .toList();
    for (final s in userScores) {
      if (s.id != score.id) {
        score.board.scores.remove(s);
      }
    }
    score.state = ScoreState.approved;
  }
}
