import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'router.dart';
import 'theme/theme.dart';

class ScoreboardApp extends StatelessWidget {
  const ScoreboardApp({super.key, required this.repository});

  final Repository repository;

  static const locale = Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn');

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => GamesBloc(repository)..add(const GamesLoad()),
        ),
        BlocProvider(
          create: (_) => MyEntriesBloc(repository)..add(const MyEntriesLoad()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Scoreboard',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        locale: locale,
        supportedLocales: const [locale],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: createRouter(repository),
      ),
    );
  }
}
