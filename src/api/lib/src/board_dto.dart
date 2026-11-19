import 'package:scoreboard_api/src/game_dto.dart';

final class BoardDto {
  const BoardDto({required this.id, required this.limit, required this.game});

  final int id;
  final int limit;
  final GameDto game;

  factory BoardDto.fromJson(Map<String, dynamic> json) => BoardDto(
        id: json['id'] as int,
        limit: json['limit'] as int,
        game: GameDto.fromJson(json['game'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'limit': limit,
        'game': game.toJson(),
      };
}
