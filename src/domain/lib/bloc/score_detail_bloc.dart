import 'package:bloc/bloc.dart';

import 'package:domain/board.dart';
import 'package:domain/errors.dart';
import 'package:domain/repository.dart';

sealed class ScoreDetailEvent {
  const ScoreDetailEvent();
}

class ScoreDetailLoad extends ScoreDetailEvent {
  const ScoreDetailLoad(this.scoreId);

  final int scoreId;
}

class ScoreDetailWithdraw extends ScoreDetailEvent {
  const ScoreDetailWithdraw();
}

sealed class ScoreDetailState {
  const ScoreDetailState();
}

class ScoreDetailInitial extends ScoreDetailState {
  const ScoreDetailInitial();
}

class ScoreDetailLoading extends ScoreDetailState {
  const ScoreDetailLoading();
}

abstract class ScoreDetailWithScore extends ScoreDetailState {
  const ScoreDetailWithScore();

  Score get score;
}

class ScoreDetailLoaded extends ScoreDetailWithScore {
  const ScoreDetailLoaded(this.score);

  @override
  final Score score;
}

class ScoreDetailWithdrawn extends ScoreDetailWithScore {
  const ScoreDetailWithdrawn(this.score);

  @override
  final Score score;
}

class ScoreDetailNotFound extends ScoreDetailState {
  const ScoreDetailNotFound();
}

class ScoreDetailError extends ScoreDetailState {
  const ScoreDetailError(this.message);

  final String message;
}

class ScoreDetailBloc extends Bloc<ScoreDetailEvent, ScoreDetailState> {
  ScoreDetailBloc(this._repository) : super(const ScoreDetailInitial()) {
    on<ScoreDetailLoad>(_onLoad);
    on<ScoreDetailWithdraw>(_onWithdraw);
  }

  final Repository _repository;

  Future<void> _onLoad(ScoreDetailLoad event, Emitter<ScoreDetailState> emit) async {
    emit(const ScoreDetailLoading());
    try {
      final score = await _repository.fetchScore(event.scoreId);
      if (score == null) {
        emit(const ScoreDetailNotFound());
      } else {
        emit(ScoreDetailLoaded(score));
      }
    } on DomainException catch (error) {
      emit(ScoreDetailError(error.message));
    } catch (error) {
      emit(ScoreDetailError(error.toString()));
    }
  }

  Future<void> _onWithdraw(ScoreDetailWithdraw event, Emitter<ScoreDetailState> emit) async {
    if (state is! ScoreDetailWithScore) return;
    try {
      final withScore = state as ScoreDetailWithScore;
      await _repository.withdrawScore(withScore.score.id);
      emit(ScoreDetailWithdrawn(withScore.score));
    } on DomainException catch (error) {
      emit(ScoreDetailError(error.message));
    } catch (error) {
      emit(ScoreDetailError(error.toString()));
    }
  }
}
