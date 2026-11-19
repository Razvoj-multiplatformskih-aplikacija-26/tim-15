import 'package:bloc/bloc.dart';

import 'package:domain/errors.dart';
import 'package:domain/repository.dart';
import 'package:domain/user.dart';

sealed class AuthEvent {
  const AuthEvent();
}

class AuthRestore extends AuthEvent {
  const AuthRestore();
}

class AuthLogin extends AuthEvent {
  const AuthLogin({required this.username, required this.password});

  final String username;
  final String password;
}

class AuthLogout extends AuthEvent {
  const AuthLogout();
}

class AuthSessionExpired extends AuthEvent {
  const AuthSessionExpired();
}

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthRestoring extends AuthState {
  const AuthRestoring();
}

class AuthLoggedOut extends AuthState {
  const AuthLoggedOut();
}

class AuthLoggedIn extends AuthState {
  const AuthLoggedIn(this.user);

  final User user;
}

class AuthLoginLoading extends AuthState {
  const AuthLoginLoading();
}

class AuthLoginError extends AuthState {
  const AuthLoginError(this.message);

  final String message;
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository) : super(const AuthInitial()) {
    on<AuthRestore>(_onRestore);
    on<AuthLogin>(_onLogin);
    on<AuthLogout>(_onLogout);
    on<AuthSessionExpired>(_onSessionExpired);
  }

  final AuthRepository _repository;

  Future<void> _onRestore(AuthRestore event, Emitter<AuthState> emit) async {
    emit(const AuthRestoring());
    final user = await _repository.getSession();
    emit(user == null ? const AuthLoggedOut() : AuthLoggedIn(user));
  }

  Future<void> _onLogin(AuthLogin event, Emitter<AuthState> emit) async {
    emit(const AuthLoginLoading());
    try {
      final user = await _repository.login(event.username, event.password);
      emit(AuthLoggedIn(user));
    } on DomainException catch (error) {
      emit(AuthLoginError(error.message));
    } catch (error) {
      emit(const AuthLoginError('Something went wrong. Please try again.'));
    }
  }

  Future<void> _onLogout(AuthLogout event, Emitter<AuthState> emit) async {
    await _repository.logout();
    emit(const AuthLoggedOut());
  }

  void _onSessionExpired(AuthSessionExpired event, Emitter<AuthState> emit) {
    emit(const AuthLoggedOut());
  }
}
