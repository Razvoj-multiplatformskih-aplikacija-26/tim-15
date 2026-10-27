import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';

final currentUser = User(id: 'u-1', username: 'gost', role: Role.guest);

final fakeUsers = <User>[
  currentUser,
  User(id: 'u-2', username: 'Megi', role: Role.guest),
  User(id: 'u-3', username: 'Lena', role: Role.guest),
  User(id: 'u-4', username: 'Masa', role: Role.guest),
  User(id: 'u-5', username: 'Anja', role: Role.guest),
  User(id: 'u-6', username: 'Djordje', role: Role.guest),
  User(id: 'u-7', username: 'Ivana', role: Role.guest),
  User(id: 'u-8', username: 'Tara', role: Role.guest),
  User(id: 'u-9', username: 'Filip', role: Role.guest),
];

final fakeGames = <Game>[
  Game(id: 1, name: 'Tetris', genre: 'Puzzle', releaseDate: DateTime(1984)),
  Game(id: 2, name: 'Minecraft Speedrun', genre: 'Sandbox', releaseDate: DateTime(2011)),
  Game(id: 3, name: 'CS2 Aim Trainer', genre: 'Shooter', releaseDate: DateTime(2023)),
  Game(id: 4, name: 'Chess', genre: 'Strategy', releaseDate: DateTime(1475)),
];

final fakeBoards = <Board>[
  Board(id: 1, limit: 10000, game: fakeGames[0]),
  Board(id: 2, limit: 10000, game: fakeGames[1]),
  Board(id: 3, limit: 5, game: fakeGames[2]),
  Board(id: 4, limit: 100, game: fakeGames[3]),
];

Score _makeScore({
  required int id,
  required int scoreValue,
  required Board board,
  required User user,
  required ScoreState state,
  int daysAgo = 0,
}) {
  final now = DateTime.now().subtract(Duration(days: daysAgo));
  final s = Score(
    id: id,
    name: 'Score $id',
    createdAt: now,
    lastModified: now,
    score: scoreValue,
    board: board,
    user: user,
  );
  s.state = state;
  return s;
}

void _populateFakeData() {
  // Tetris
  fakeBoards[0].scores.addAll([
    _makeScore(id: 1, scoreValue: 15000, board: fakeBoards[0], user: fakeUsers[1], state: ScoreState.approved),
    _makeScore(id: 3, scoreValue: 18000, board: fakeBoards[0], user: fakeUsers[2], state: ScoreState.approved),
    _makeScore(id: 4, scoreValue: 9000, board: fakeBoards[0], user: fakeUsers[3], state: ScoreState.approved),
    _makeScore(id: 5, scoreValue: 4000, board: fakeBoards[0], user: fakeUsers[4], state: ScoreState.approved),
    _makeScore(id: 6, scoreValue: 2000, board: fakeBoards[0], user: fakeUsers[5], state: ScoreState.approved),
    _makeScore(id: 7, scoreValue: 13000, board: fakeBoards[0], user: fakeUsers[6], state: ScoreState.approved),
    _makeScore(id: 8, scoreValue: 900, board: fakeBoards[0], user: fakeUsers[7], state: ScoreState.approved),
    _makeScore(id: 9, scoreValue: 4600, board: fakeBoards[0], user: fakeUsers[0], state: ScoreState.pending),
    _makeScore(id: 10, scoreValue: 1000, board: fakeBoards[0], user: fakeUsers[2], state: ScoreState.rejected),
    _makeScore(id: 101, scoreValue: 12000, board: fakeBoards[0], user: currentUser, state: ScoreState.approved, daysAgo: 5),
  ]);

  // Minecraft
  fakeBoards[1].scores.addAll([
    _makeScore(id: 11, scoreValue: 300, board: fakeBoards[1], user: fakeUsers[1], state: ScoreState.approved),
    _makeScore(id: 12, scoreValue: 250, board: fakeBoards[1], user: fakeUsers[2], state: ScoreState.approved),
    _makeScore(id: 102, scoreValue: 400, board: fakeBoards[1], user: currentUser, state: ScoreState.rejected, daysAgo: 2),
  ]);

  // CS2
  fakeBoards[2].scores.addAll([
    _makeScore(id: 15, scoreValue: 950, board: fakeBoards[2], user: fakeUsers[1], state: ScoreState.approved),
    _makeScore(id: 16, scoreValue: 700, board: fakeBoards[2], user: fakeUsers[4], state: ScoreState.archived),
    _makeScore(id: 103, scoreValue: 800, board: fakeBoards[2], user: currentUser, state: ScoreState.pending, daysAgo: 1),
  ]);
}

bool _initialized = false;
void initializeFakeData() {
  if (_initialized) return;
  _populateFakeData();
  _initialized = true;
}

List<Score> getMyScores() {
  final List<Score> myScores = [];
  for (final board in fakeBoards) {
    myScores.addAll(board.scores.where((s) => s.user.id == currentUser.id));
  }
  return myScores..sort((a, b) => b.createdAt.compareTo(a.createdAt));
}

class FakeDataNotifier extends ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}

final fakeDataNotifier = FakeDataNotifier();

void approveScore(Score score) {
  final userScores = score.board.scores
      .where((s) => s.user.id == score.user.id)
      .toList();

  for (final s in userScores) {
    if (s.id != score.id) {
      score.board.scores.remove(s);
    }
  }
  score.state = ScoreState.approved;

  fakeDataNotifier.notify();
}