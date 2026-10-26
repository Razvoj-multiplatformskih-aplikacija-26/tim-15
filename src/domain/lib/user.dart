import 'package:domain/board.dart';

enum Role { guest, admin }

class User {
  final String id;
  final String username;
  final Role role;
  final bool active = true;
  final List<Score> scores = [];

  User({
    required this.id,
    required this.username,
    required this.role,
  });

  void submitScore(Score score, Board board) {
    if (!board.scores.contains(score)) {
      board.addScore(score);
    } else {
      // For now since we're just mocking
      Score here = board.scores.firstWhere((s) => s.user.id == id);
      board.scores.remove(here);
      board.addScore(score);
    }
  }
}
