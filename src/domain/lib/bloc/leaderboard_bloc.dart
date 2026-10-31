import 'package:bloc/bloc.dart';

import 'package:domain/board.dart';
import 'package:domain/errors.dart';
import 'package:domain/game.dart';
import 'package:domain/repository.dart';

sealed class LeaderboardEvent {
  const LeaderboardEvent();
}

class LeaderboardLoad extends LeaderboardEvent {
  const LeaderboardLoad(this.gameId);

  final int gameId;
}

class LeaderboardReload extends LeaderboardEvent {
  const LeaderboardReload();
}

sealed class LeaderboardState {
  const LeaderboardState();
}

class LeaderboardInitial extends LeaderboardState {}

class LeaderboardLoading extends LeaderboardState {}

class LeaderboardLoaded extends LeaderboardState {
  const LeaderboardLoaded(this.game, this.scores);

  final Game game;
  final List<Score> scores;
}

class LeaderboardError extends LeaderboardState {
  const LeaderboardError(this.message);

  final String message;
}

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  LeaderboardBloc(this._repository) : super(LeaderboardInitial()) {
    on<LeaderboardLoad>(_onLoad);
    on<LeaderboardReload>(_onReload);
  }

  final Repository _repository;
  int? _gameId;

  Future<void> _onLoad(LeaderboardLoad event, Emitter<LeaderboardState> emit) async {
    _gameId = event.gameId;
    await _runLoad(emit);
  }

  Future<void> _onReload(LeaderboardReload event, Emitter<LeaderboardState> emit) async {
    final gameId = _gameId;
    if (gameId == null) return;
    await _runLoad(emit);
  }

  Future<void> _runLoad(Emitter<LeaderboardState> emit) async {
    final gameId = _gameId!;
    emit(LeaderboardLoading());
    try {
      final result = await Future.wait([
        _repository.fetchGame(gameId),
        _repository.fetchLeaderboard(gameId),
      ]);
      final game = result[0] as Game;
      final scores = result[1] as List<Score>;
      emit(LeaderboardLoaded(game, scores));
    } on DomainException catch (error) {
      emit(LeaderboardError(error.message));
    } catch (error) {
      emit(LeaderboardError(error.toString()));
    }
  }
}
