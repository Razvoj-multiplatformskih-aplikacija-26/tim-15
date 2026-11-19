class Config {
  const Config({
    required this.databaseUrl,
    this.port = 8080,
    this.sessionTtl = const Duration(hours: 24),
  });

  final String databaseUrl;
  final int port;
  final Duration sessionTtl;

  factory Config.fromEnv(Map<String, String> env) {
    final ttlHours = int.tryParse(env['SESSION_TTL_HOURS'] ?? '') ?? 24;
    return Config(
      databaseUrl: env['DATABASE_URL'] ??
          'postgres://scoreboard:scoreboard@localhost:5432/scoreboard'
          '?sslmode=disable',
      port: int.tryParse(env['PORT'] ?? '') ?? 8080,
      sessionTtl: Duration(hours: ttlHours.clamp(1, 720)),
    );
  }
}
