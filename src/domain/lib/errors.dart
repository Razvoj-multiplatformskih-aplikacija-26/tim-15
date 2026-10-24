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
