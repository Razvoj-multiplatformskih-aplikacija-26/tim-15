import 'package:domain/board.dart';

abstract class DomainException implements Exception {
  final String message;

  DomainException(this.message);

  @override
  String toString() => 'DomainError: $message';
}

class ScoreOverLimitException extends DomainException {
  ScoreOverLimitException(super.message, this.score);

  final Score score;
}

class PermissionDeniedException extends DomainException {
  PermissionDeniedException(super.message);
}

class NotFoundException extends DomainException {
  NotFoundException(super.message);
}

class ValidationException extends DomainException {
  ValidationException(super.message);
}

class ConflictException extends DomainException {
  ConflictException(super.message);
}

class ScoreRangeViolation extends ValidationException {
  ScoreRangeViolation({
    required String message,
    required this.value,
    required this.maxScore,
  }) : super(message);

  final int value;
  final int maxScore;
}

class LeaderboardCapacityViolation extends ConflictException {
  LeaderboardCapacityViolation({
    required String message,
    required this.gameName,
    required this.value,
    required this.capacity,
  }) : super(message);

  final String gameName;
  final int value;
  final int capacity;
}

class AuthException extends DomainException {
  AuthException(super.message);
}

class SessionExpiredException extends DomainException {
  SessionExpiredException(super.message);
}

class NetworkException extends DomainException {
  NetworkException(super.message);
}

class ServerErrorException extends DomainException {
  ServerErrorException(super.message);
}
