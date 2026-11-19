import 'package:domain/domain.dart';
import 'package:scoreboard_api/scoreboard_api.dart';

Game toDomainGame(GameDto dto) => Game(
      id: dto.id,
      name: dto.name,
      genre: dto.genre,
      releaseDate: dto.releaseDate,
    );

Board toDomainBoard(BoardDto dto) => Board(
      id: dto.id,
      limit: dto.limit,
      game: toDomainGame(dto.game),
    );

User toDomainUser(UserDto dto) => User(
      id: dto.id,
      username: dto.username,
      role: dto.role == RoleDto.admin ? Role.admin : Role.guest,
      active: dto.active,
    );

Score toDomainScore(ScoreDto dto) {
  final score = Score(
    id: dto.id,
    name: dto.name,
    createdAt: dto.createdAt,
    lastModified: dto.lastModified,
    score: dto.value,
    board: toDomainBoard(dto.board),
    user: toDomainUser(dto.user),
  );
  score.state = switch (dto.state) {
    ScoreStateDto.pending => ScoreState.pending,
    ScoreStateDto.approved => ScoreState.approved,
    ScoreStateDto.rejected => ScoreState.rejected,
    ScoreStateDto.archived => ScoreState.archived,
  };
  return score;
}
