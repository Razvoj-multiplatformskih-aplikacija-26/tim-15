import 'package:bloc/bloc.dart';

import 'package:domain/errors.dart';
import 'package:domain/game.dart';
import 'package:domain/repository.dart';

sealed class GamesEvent {
  const GamesEvent();
}

class GamesLoad extends GamesEvent {
  const GamesLoad();
}

sealed class GamesState {
  const GamesState();
}

class GamesInitial extends GamesState {}

class GamesLoading extends GamesState {}

class GamesLoaded extends GamesState {
  const GamesLoaded(this.games);

  final List<Game> games;
}

class GamesError extends GamesState {
  const GamesError(this.message);

  final String message;
}

class GamesBloc extends Bloc<GamesEvent, GamesState> {
  GamesBloc(this._repository) : super(GamesInitial()) {
    on<GamesLoad>(_onLoad);
  }

  final Repository _repository;

  Future<void> _onLoad(GamesLoad event, Emitter<GamesState> emit) async {
    emit(GamesLoading());
    try {
      final games = await _repository.fetchGames();
      emit(GamesLoaded(games));
    } on DomainException catch (error) {
      emit(GamesError(error.message));
    } catch (error) {
      emit(GamesError(error.toString()));
    }
  }
}
