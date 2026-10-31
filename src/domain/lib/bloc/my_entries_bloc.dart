import 'package:bloc/bloc.dart';

import 'package:domain/board.dart';
import 'package:domain/errors.dart';
import 'package:domain/repository.dart';

sealed class MyEntriesEvent {
  const MyEntriesEvent();
}

class MyEntriesLoad extends MyEntriesEvent {
  const MyEntriesLoad();
}

class MyEntriesWithdraw extends MyEntriesEvent {
  const MyEntriesWithdraw(this.scoreId);

  final int scoreId;
}

class MyEntriesApprove extends MyEntriesEvent {
  const MyEntriesApprove(this.scoreId);

  final int scoreId;
}

sealed class MyEntriesState {
  const MyEntriesState();
}

class MyEntriesInitial extends MyEntriesState {
  const MyEntriesInitial();
}

class MyEntriesLoading extends MyEntriesState {
  const MyEntriesLoading();
}

abstract class MyEntriesWithScores extends MyEntriesState {
  const MyEntriesWithScores();

  List<Score> get scores;
}

class MyEntriesLoaded extends MyEntriesWithScores {
  const MyEntriesLoaded(this.scores);

  @override
  final List<Score> scores;
}

class MyEntriesWithdrawn extends MyEntriesWithScores {
  const MyEntriesWithdrawn(this.scores);

  @override
  final List<Score> scores;
}

class MyEntriesApproved extends MyEntriesWithScores {
  const MyEntriesApproved(this.scores);

  @override
  final List<Score> scores;
}

class MyEntriesError extends MyEntriesState {
  const MyEntriesError(this.message);

  final String message;
}

class MyEntriesBloc extends Bloc<MyEntriesEvent, MyEntriesState> {
  MyEntriesBloc(this._repository) : super(const MyEntriesInitial()) {
    on<MyEntriesLoad>(_onLoad);
    on<MyEntriesWithdraw>(_onWithdraw);
    on<MyEntriesApprove>(_onApprove);
  }

  final Repository _repository;

  Future<void> _onLoad(MyEntriesLoad event, Emitter<MyEntriesState> emit) async {
    emit(const MyEntriesLoading());
    try {
      final scores = await _repository.fetchMyScores();
      emit(MyEntriesLoaded(scores));
    } on DomainException catch (error) {
      emit(MyEntriesError(error.message));
    } catch (error) {
      emit(MyEntriesError(error.toString()));
    }
  }

  Future<void> _onWithdraw(MyEntriesWithdraw event, Emitter<MyEntriesState> emit) async {
    if (state is! MyEntriesWithScores) return;
    try {
      await _repository.withdrawScore(event.scoreId);
      final withScores = state as MyEntriesWithScores;
      emit(MyEntriesWithdrawn(List<Score>.from(withScores.scores)));
    } on DomainException catch (error) {
      emit(MyEntriesError(error.message));
    } catch (error) {
      emit(MyEntriesError(error.toString()));
    }
  }

  Future<void> _onApprove(MyEntriesApprove event, Emitter<MyEntriesState> emit) async {
    if (state is! MyEntriesWithScores) return;
    try {
      await _repository.approveScore(event.scoreId);
      final withScores = state as MyEntriesWithScores;
      emit(MyEntriesApproved(List<Score>.from(withScores.scores)));
    } on DomainException catch (error) {
      emit(MyEntriesError(error.message));
    } catch (error) {
      emit(MyEntriesError(error.toString()));
    }
  }
}
