import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:scoreboard_api_client/scoreboard_api_client.dart';

final class SecureTokenStore implements TokenStore {
  SecureTokenStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              webOptions: WebOptions(dbName: 'scoreboard_session'),
            );

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'scoreboard.session_token';

  @override
  Future<String?> readToken() => _storage.read(key: _tokenKey);

  @override
  Future<void> writeToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  @override
  Future<void> clear() => _storage.delete(key: _tokenKey);
}
