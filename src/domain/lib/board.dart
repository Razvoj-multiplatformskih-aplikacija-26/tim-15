import 'package:domain/errors.dart';
import 'package:domain/game.dart';

enum ScoreState {
  pending,
  approved,
  rejected
}

class Score {
  Score({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.lastModified,
    required this.score,
    required this.board
  });

  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime lastModified;
  final int score;
  final Board board;
  ScoreState state = ScoreState.pending;
}

class Board {
  Board({
    required this.id,
    required this.limit,
    required this.game
  });

  final int id;
  final int limit;
  final Game game;
  final List<Score> scores = List.empty();

  void addScore(Score score) {
    if (score.score <= limit) {
      score.state = ScoreState.approved;
      scores.add(score);
    } else {
      score.state = ScoreState.rejected;
      throw ScoreOverLimitException('Score exceeds the limit of $limit', score);
    }
  }
}
