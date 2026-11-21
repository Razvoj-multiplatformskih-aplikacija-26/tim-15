import 'package:scoreboard_api/scoreboard_api.dart';
import 'package:test/test.dart';

void main() {
  test('UserDto round trip', () {
    const dto = UserDto(
      id: '7',
      username: 'Lena',
      role: RoleDto.guest,
      active: true,
    );
    final decoded = UserDto.fromJson(dto.toJson());
    expect(decoded.id, dto.id);
    expect(decoded.username, dto.username);
    expect(decoded.role, dto.role);
    expect(decoded.active, dto.active);
  });

  test('ScoreDto round trip', () {
    final dto = ScoreDto(
      id: 15,
      name: 'Submission',
      createdAt: DateTime.utc(2025, 4, 1, 10),
      lastModified: DateTime.utc(2025, 4, 2, 11),
      value: 950,
      state: ScoreStateDto.approved,
      board: BoardDto(
        id: 3,
        maxScore: 5,
        capacity: 5,
        game: GameDto(
          id: 3,
          name: 'CS2 Aim Trainer',
          genre: 'Shooter',
          releaseDate: DateTime.utc(2023),
        ),
      ),
      user: const UserDto(
        id: '2',
        username: 'Megi',
        role: RoleDto.guest,
        active: true,
      ),
    );
    final decoded = ScoreDto.fromJson(dto.toJson());
    expect(decoded, isA<ScoreDto>());
    expect(decoded.id, 15);
    expect(decoded.value, 950);
    expect(decoded.state, ScoreStateDto.approved);
    expect(decoded.board.id, 3);
    expect(decoded.board.maxScore, 5);
    expect(decoded.board.capacity, 5);
    expect(decoded.board.game.name, 'CS2 Aim Trainer');
    expect(decoded.user.username, 'Megi');
  });

  test('ApiError parses server error envelope', () {
    final error = ApiError.fromJson({'code': 'conflict', 'message': 'Nope.'});
    expect(error.code, 'conflict');
    expect(error.message, 'Nope.');
    expect(ApiError.fromJson({}).code, ApiErrorCode.internal);
  });
}
