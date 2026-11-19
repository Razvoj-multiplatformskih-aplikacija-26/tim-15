import 'dart:async';
import 'dart:convert';

import 'package:domain/domain.dart';
import 'package:http/http.dart' as http;
import 'package:scoreboard_api/scoreboard_api.dart';

import 'token_store.dart';

final class ScoreboardApiClient {
  ScoreboardApiClient(
    this._http, {
    required this._baseUrl,
    required this._tokenStore,
    this._onUnauthorized,
    this.timeout = const Duration(seconds: 15),
  });

  final http.Client _http;
  final Uri _baseUrl;
  final TokenStore _tokenStore;
  final Duration timeout;
  final void Function()? _onUnauthorized;
  String? _token;

  Future<String?> _resolveToken() async {
    final cached = _token;
    if (cached != null) return cached;
    final stored = await _tokenStore.readToken();
    _token = stored;
    return stored;
  }

  Future<void> _clearStoredToken() async {
    _token = null;
    _tokenStore.clear().ignore();
  }

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _send<LoginResponse>(
      'POST',
      Endpoints.login(),
      body: request.toJson(),
      auth: false,
      parse: (decoded) =>
          LoginResponse.fromJson(decoded as Map<String, dynamic>),
    );
    _token = response.token;
    await _tokenStore.writeToken(response.token);
    return response;
  }

  Future<void> logout() =>
      _send<void>('POST', Endpoints.logout());

  Future<UserDto> me() => _send<UserDto>(
        'GET',
        Endpoints.me(),
        parse: (decoded) =>
            UserDto.fromJson(decoded as Map<String, dynamic>),
      );

  Future<List<GameDto>> games() => _send<List<GameDto>>(
        'GET',
        Endpoints.games(),
        parse: (decoded) => (decoded as List<dynamic>)
            .map((e) => GameDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Future<GameDto> game(int id) => _send<GameDto>(
        'GET',
        Endpoints.game(id),
        parse: (decoded) => GameDto.fromJson(decoded as Map<String, dynamic>),
      );

  Future<BoardDto> board(int gameId) => _send<BoardDto>(
        'GET',
        Endpoints.board(gameId),
        parse: (decoded) =>
            BoardDto.fromJson(decoded as Map<String, dynamic>),
      );

  Future<List<ScoreDto>> leaderboard(int gameId) =>
      _send<List<ScoreDto>>(
        'GET',
        Endpoints.leaderboard(gameId),
        parse: (decoded) => (decoded as List<dynamic>)
            .map((e) => ScoreDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Future<ScoreDto?> score(int id) => _send<ScoreDto?>(
        'GET',
        Endpoints.score(id),
        parse: (decoded) => decoded == null
            ? null
            : ScoreDto.fromJson(decoded as Map<String, dynamic>),
      );

  Future<List<ScoreDto>> myScores() => _send<List<ScoreDto>>(
        'GET',
        Endpoints.myScores(),
        parse: (decoded) => (decoded as List<dynamic>)
            .map((e) => ScoreDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Future<List<ScoreDto>> allScores() => _send<List<ScoreDto>>(
        'GET',
        Endpoints.scores(),
        parse: (decoded) => (decoded as List<dynamic>)
            .map((e) => ScoreDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Future<ScoreDto> submitScore(int gameId, SubmitScoreRequest request) =>
      _send<ScoreDto>(
        'POST',
        Endpoints.submit(gameId),
        body: request.toJson(),
        parse: (decoded) =>
            ScoreDto.fromJson(decoded as Map<String, dynamic>),
      );

  Future<void> withdrawScore(int id) =>
      _send<void>('POST', Endpoints.withdraw(id));

  Future<void> approveScore(int id) =>
      _send<void>('POST', Endpoints.approve(id));

  Future<void> rejectScore(int id) =>
      _send<void>('POST', Endpoints.reject(id));

  Future<void> health() =>
      _send<void>('GET', Endpoints.health(), auth: false);

  Future<T> _send<T>(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
    bool retried = false,
    T Function(Object? decoded)? parse,
  }) async {
    final headers = <String, String>{'accept': 'application/json'};
    if (body != null) headers['content-type'] = 'application/json';
    if (auth) {
      final token = await _resolveToken();
      if (token != null) headers['authorization'] = 'Bearer $token';
    }

    final request = http.Request(method, _baseUrl.resolve(path))
      ..headers.addAll(headers);
    if (body != null) request.body = jsonEncode(body);

    final http.StreamedResponse response;
    try {
      response = await _http.send(request).timeout(timeout);
    } on TimeoutException {
      throw NetworkException(
          'The server did not respond in time. Please try again.');
    } catch (_) {
      throw NetworkException(
          'Cannot reach the server. Please check your connection and try again.');
    }

    final bytes = await response.stream.toBytes();
    final status = response.statusCode;

    if (status >= 200 && status < 300) {
      if (parse == null) return (null as T);
      return parse(_decodeJson(bytes));
    }

    if (status == 401 && auth && !retried && _token != null) {
      _token = null;
      await _clearStoredToken();
      _onUnauthorized?.call();
      return _send<T>(
        method,
        path,
        body: body,
        auth: auth,
        retried: true,
        parse: parse,
      );
    }

    throw _mapError(status, bytes);
  }

  Object? _decodeJson(List<int> bytes) {
    if (bytes.isEmpty) return null;
    try {
      return jsonDecode(utf8.decode(bytes));
    } on FormatException {
      return null;
    }
  }

  DomainException _mapError(int status, List<int> bytes) {
    var code = ApiErrorCode.internal;
    var message = 'Something went wrong. Please try again later.';
    final decoded = _decodeJson(bytes);
    if (decoded is Map<String, dynamic>) {
      final decodedCode = decoded['code'];
      final decodedMessage = decoded['message'];
      if (decodedCode is String && decodedCode.isNotEmpty) {
        code = decodedCode;
      }
      if (decodedMessage is String && decodedMessage.isNotEmpty) {
        message = decodedMessage;
      }
    }

    return switch (code) {
      ApiErrorCode.invalidCredentials => AuthException(message),
      ApiErrorCode.userDisabled => AuthException(message),
      ApiErrorCode.unauthenticated => SessionExpiredException(message),
      ApiErrorCode.forbidden => PermissionDeniedException(message),
      ApiErrorCode.notFound => NotFoundException(message),
      ApiErrorCode.validation || ApiErrorCode.overLimit =>
        ValidationException(message),
      ApiErrorCode.conflict => ConflictException(message),
      _ => ServerErrorException(message),
    };
  }
}
