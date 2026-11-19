import 'package:scoreboard_api/src/board_dto.dart';
import 'package:scoreboard_api/src/user_dto.dart';

enum ScoreStateDto { pending, approved, rejected, archived }

extension ScoreStateDtoJson on ScoreStateDto {
  String get wire => name;

  static ScoreStateDto fromWire(String value) => ScoreStateDto.values
      .firstWhere((e) => e.name == value, orElse: () => ScoreStateDto.pending);
}

final class ScoreDto {
  const ScoreDto({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.lastModified,
    required this.value,
    required this.state,
    required this.board,
    required this.user,
  });

  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime lastModified;
  final int value;
  final ScoreStateDto state;
  final BoardDto board;
  final UserDto user;

  factory ScoreDto.fromJson(Map<String, dynamic> json) => ScoreDto(
        id: json['id'] as int,
        name: json['name'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastModified: DateTime.parse(json['lastModified'] as String),
        value: json['value'] as int,
        state: ScoreStateDtoJson.fromWire(json['state'] as String),
        board: BoardDto.fromJson(json['board'] as Map<String, dynamic>),
        user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'lastModified': lastModified.toIso8601String(),
        'value': value,
        'state': state.wire,
        'board': board.toJson(),
        'user': user.toJson(),
      };
}
