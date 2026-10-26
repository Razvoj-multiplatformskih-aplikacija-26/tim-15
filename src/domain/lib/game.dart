import 'package:domain/board.dart';

class Game {
  Game({
    required this.id,
    required this.name,
    required this.genre,
    required this.releaseDate,
  });

  final int id;
  final String name;
  final String genre;
  final DateTime releaseDate;
  final List<Board> boards = [];
}
