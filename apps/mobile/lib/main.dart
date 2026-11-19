import 'package:domain/domain.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:scoreboard_api_client/scoreboard_api_client.dart';
import 'package:scoreboard_platform/scoreboard_platform.dart';

import 'app.dart';

const String serverUrl = String.fromEnvironment(
  'SERVER_URL',
  defaultValue: 'http://localhost:8080',
);

void main() {
  late final AuthBloc auth;
  final client = ScoreboardApiClient(
    http.Client(),
    baseUrl: Uri.parse(serverUrl),
    tokenStore: SecureTokenStore(),
    onUnauthorized: () => auth.add(const AuthSessionExpired()),
  );
  final authRepository = ServerAuthRepository(client);
  auth = AuthBloc(authRepository)..add(const AuthRestore());
  runApp(
    ScoreboardApp(
      auth: auth,
      repository: ServerRepository(client, authRepository),
    ),
  );
}
