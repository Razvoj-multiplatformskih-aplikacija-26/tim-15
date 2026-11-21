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
      maxScore: dto.maxScore,
      capacity: dto.capacity,
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

DomainException toDomainApiError(ApiError error) {
  final details = error.details;
  if (details['rule'] == ApiErrorRule.scoreRange) {
    final value = details['value'];
    final maxScore = details['maxScore'];
    if (value is int && maxScore is int) {
      final message = validateScoreValue(value: value, maxScore: maxScore);
      if (message != null) return ValidationException(message);
    }
  }
  if (details['rule'] == ApiErrorRule.leaderboardCapacity) {
    final gameName = details['gameName'];
    final value = details['value'];
    final capacity = details['capacity'];
    if (gameName is String && value is int && capacity is int) {
      return ConflictException(leaderboardCapacityMessage(
        gameName: gameName,
        value: value,
        capacity: capacity,
      ));
    }
  }

  return switch (error.code) {
    ApiErrorCode.invalidCredentials => AuthException(error.message),
    ApiErrorCode.userDisabled => AuthException(error.message),
    ApiErrorCode.unauthenticated => SessionExpiredException(error.message),
    ApiErrorCode.forbidden => PermissionDeniedException(error.message),
    ApiErrorCode.notFound => NotFoundException(error.message),
    ApiErrorCode.validation || ApiErrorCode.overLimit =>
      ValidationException(error.message),
    ApiErrorCode.conflict => ConflictException(error.message),
    _ => ServerErrorException(error.message),
  };
}
