import 'dart:async';
import 'dart:io';

import 'package:relic/relic.dart';
import 'package:server/server.dart';

Future<void> main() async {
  final config = Config.fromEnv(Platform.environment);
  final database = await Database.open(config.databaseUrl);
  try {
    await runMigrations(database);
    await seedIfEmpty(database);

    final app = createApp(database, config);
    await app.serve(address: InternetAddress.anyIPv4, port: config.port);
    stdout
        .writeln('Scoreboard server is running on http://localhost:${config.port}');

    final shutdown = Completer<void>();
    ProcessSignal.sigint.watch().listen((_) => shutdown.complete());
    await shutdown.future;
  } finally {
    await database.close();
  }
}
