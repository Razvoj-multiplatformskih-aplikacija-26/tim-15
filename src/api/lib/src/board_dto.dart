import 'package:scoreboard_api/src/game_dto.dart';

final class BoardDto {
  const BoardDto({
    required this.id,
    required this.maxScore,
    required this.capacity,
    required this.game,
  });

  final int id;
  final int maxScore;
  final int capacity;
  final GameDto game;

  factory BoardDto.fromJson(Map<String, dynamic> json) => BoardDto(
        id: json['id'] as int,
        maxScore: (json['maxScore'] as int?) ?? (json['limit'] as int),
        capacity: (json['capacity'] as int?) ?? (json['limit'] as int),
        game: GameDto.fromJson(json['game'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'maxScore': maxScore,
        'capacity': capacity,
        'limit': maxScore,
        'game': game.toJson(),
      };
}
