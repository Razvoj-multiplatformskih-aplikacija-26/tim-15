import 'dart:async';

import 'package:postgres/postgres.dart';

final class Database {
  Database._(this._pool, this.url);

  final Pool _pool;
  final String url;

  static Future<Database> open(String url) async {
    final database = Database._(Pool.withUrl(url), url);
    await database._ensureDatabaseExists();
    return database;
  }

  Pool get pool => _pool;

  String get databaseName => Uri.parse(url).pathSegments.first;

  Future<void> _ensureDatabaseExists() async {
    final uri = Uri.parse(url);
    final databaseName = uri.pathSegments.first;
    final adminUri = uri.replace(path: '/postgres');
    final admin = await Connection.openFromUrl(adminUri.toString());
    try {
      final existing = await admin.execute(
        'SELECT 1 FROM pg_database WHERE datname = \$1',
        parameters: [databaseName],
      );
      if (existing.isEmpty) {
        await admin.execute(
          'CREATE DATABASE "${databaseName.replaceAll('"', '""')}"',
        );
      }
    } finally {
      await admin.close();
    }
  }

  Future<T> tx<T>(FutureOr<T> Function(TxSession session) action) =>
      _pool.runTx((session) async => action(session));

  Future<void> close() => _pool.close();
}
