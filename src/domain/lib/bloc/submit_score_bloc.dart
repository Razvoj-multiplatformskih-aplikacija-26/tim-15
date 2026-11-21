import 'package:bloc/bloc.dart';

import 'package:domain/board.dart';
import 'package:domain/errors.dart';
import 'package:domain/repository.dart';
import 'package:domain/rules.dart';

sealed class SubmitScoreEvent {
  const SubmitScoreEvent();
}

class SubmitScoreLoad extends SubmitScoreEvent {
  const SubmitScoreLoad();
}

class SubmitScoreSubmit extends SubmitScoreEvent {
  const SubmitScoreSubmit(this.value);

  final int value;
}

sealed class SubmitScoreState {
  const SubmitScoreState();
}

class SubmitScoreInitial extends SubmitScoreState {}

class SubmitScoreLoading extends SubmitScoreState {}

class SubmitScoreLoaded extends SubmitScoreState {
  const SubmitScoreLoaded(this.board);

  final Board board;
}

class SubmitScoreSubmitting extends SubmitScoreState {
  const SubmitScoreSubmitting(this.board);

  final Board board;
}

class SubmitScoreSuccess extends SubmitScoreState {
  const SubmitScoreSuccess(this.board, this.score);

  final Board board;
  final Score score;
}

class SubmitScoreError extends SubmitScoreState {
  const SubmitScoreError(this.board, this.message);

  final Board? board;
  final String message;
}

class SubmitScoreBloc extends Bloc<SubmitScoreEvent, SubmitScoreState> {
  SubmitScoreBloc(this._repository, {required this.gameId}) : super(SubmitScoreInitial()) {
    on<SubmitScoreLoad>(_onLoad);
    on<SubmitScoreSubmit>(_onSubmit);
  }

  final Repository _repository;
  final int gameId;
  Board? _board;
  List<int> _rankedValues = const [];

  Future<void> _onLoad(SubmitScoreLoad event, Emitter<SubmitScoreState> emit) async {
    emit(SubmitScoreLoading());
    try {
      await _refreshRuleData();
      emit(SubmitScoreLoaded(_board!));
    } on DomainException catch (error) {
      emit(SubmitScoreError(null, error.message));
    } catch (error) {
      emit(SubmitScoreError(null, error.toString()));
    }
  }

  Future<void> _onSubmit(SubmitScoreSubmit event, Emitter<SubmitScoreState> emit) async {
    final board = _board;
    if (board == null) return;

    final valueProblem = validateScoreValue(
      value: event.value,
      maxScore: board.maxScore,
    );
    if (valueProblem != null) {
      emit(SubmitScoreError(board, valueProblem));
      return;
    }
    if (!ranksInTopResults(
      value: event.value,
      rankedValues: _rankedValues,
      capacity: board.capacity,
    )) {
      emit(SubmitScoreError(
        board,
        leaderboardCapacityMessage(
          gameName: board.game.name,
          value: event.value,
          capacity: board.capacity,
        ),
      ));
      return;
    }

    emit(SubmitScoreSubmitting(board));
    try {
      final score = await _repository.submitScore(gameId, event.value);
      emit(SubmitScoreSuccess(board, score));
    } on DomainException catch (error) {
      await _refreshRuleDataIfPossible();
      emit(SubmitScoreError(_board ?? board, error.message));
    } catch (error) {
      await _refreshRuleDataIfPossible();
      emit(SubmitScoreError(_board ?? board, error.toString()));
    }
  }

  Future<void> _refreshRuleData() async {
    final board = await _repository.fetchBoard(gameId);
    final leaderboard = await _repository.fetchLeaderboard(gameId);
    final currentUserId = _repository.currentUser.id;
    _board = board;
    _rankedValues = leaderboard
        .where((score) => score.user.id != currentUserId)
        .map((score) => score.score)
        .toList(growable: false);
  }

  Future<void> _refreshRuleDataIfPossible() async {
    try {
      await _refreshRuleData();
    } catch (_) {

    }
  }
}
