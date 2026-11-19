import 'package:domain/domain.dart';
import 'package:scoreboard_api/scoreboard_api.dart';

import 'api_client.dart';
import 'mappers.dart';

final class ServerAuthRepository implements AuthRepository {
  ServerAuthRepository(this._client);

  final ScoreboardApiClient _client;
  User? currentUser;

  @override
  Future<User> login(String username, String password) async {
    final response =
        await _client.login(LoginRequest(username: username, password: password));
    currentUser = toDomainUser(response.user);
    return currentUser!;
  }

  @override
  Future<void> logout() async {
    _client.logout().ignore();
    currentUser = null;
  }

  @override
  Future<User?> getSession() async {
    try {
      final dto = await _client.me();
      currentUser = toDomainUser(dto);
      return currentUser;
    } on SessionExpiredException {
      currentUser = null;
      return null;
    } on AuthException {
      currentUser = null;
      return null;
    } on NetworkException {
      return null;
    }
  }
}
