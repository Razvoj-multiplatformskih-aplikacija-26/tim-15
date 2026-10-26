import 'package:domain/errors.dart';
import 'package:domain/game.dart';
import 'package:domain/user.dart';

enum ScoreState {
  pending,
  approved,
  rejected,
  archived
}

class Score {
  Score({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.lastModified,
    required this.score,
    required this.board,
    required this.user
  });

  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime lastModified;
  final int score;
  final Board board;
  final User user;
  ScoreState state = ScoreState.pending;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Score &&
        other.id == id &&
        other.name == name &&
        other.createdAt == createdAt &&
        other.lastModified == lastModified &&
        other.score == score &&
        other.board == board &&
        other.user == user;
  }

  @override
  int get hashCode => id.hashCode ^
      name.hashCode ^
      createdAt.hashCode ^
      lastModified.hashCode ^
      score.hashCode ^
      board.hashCode ^
      user.hashCode;
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
  final List<Score> scores = [];

  void addScore(Score score) {
    if (score.score <= limit) {
      scores.add(score);
    } else {
      score.state = ScoreState.rejected;
      throw ScoreOverLimitException('Score exceeds the limit of $limit', score);
    }
  }

  void deleteScore(Score score) {
    score.state = ScoreState.archived;
  }
}
