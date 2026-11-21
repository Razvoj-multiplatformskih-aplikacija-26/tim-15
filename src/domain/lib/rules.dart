import 'package:domain/board.dart';

String? validateScoreValue({required int value, required int maxScore}) {
  if (value < 0) return 'The result cannot be negative.';
  if (value > maxScore) {
    return 'The result cannot be bigger than $maxScore.';
  }
  return null;
}

bool ranksInTopResults({
  required int value,
  required Iterable<int> rankedValues,
  required int capacity,
}) {
  final rankedAhead = rankedValues.where((other) => other >= value).length;
  return rankedAhead < capacity;
}

String leaderboardCapacityMessage({
  required String gameName,
  required int value,
  required int capacity,
}) =>
    'The $gameName leaderboard is full - your result of $value '
    'does not rank in the top $capacity.';

bool canDecide(ScoreState state) => state == ScoreState.pending;

bool canWithdraw(ScoreState state) =>
    state == ScoreState.pending || state == ScoreState.approved;
