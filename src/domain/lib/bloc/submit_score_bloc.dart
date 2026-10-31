import 'package:bloc/bloc.dart';

import 'package:domain/board.dart';
import 'package:domain/errors.dart';
import 'package:domain/repository.dart';

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

  Future<void> _onLoad(SubmitScoreLoad event, Emitter<SubmitScoreState> emit) async {
    emit(SubmitScoreLoading());
    try {
      _board = await _repository.fetchBoard(gameId);
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
    emit(SubmitScoreSubmitting(board));
    try {
      final score = await _repository.submitScore(gameId, event.value);
      emit(SubmitScoreSuccess(board, score));
    } on DomainException catch (error) {
      emit(SubmitScoreError(board, error.message));
    } catch (error) {
      emit(SubmitScoreError(board, error.toString()));
    }
  }
}
