import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'router.dart';
import 'theme/theme.dart';

class BackofficeApp extends StatelessWidget {
  const BackofficeApp({
    super.key,
    required this.auth,
    required this.repository,
  });

  final AuthBloc auth;
  final Repository repository;

  static const locale =
      Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn');

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: auth,
      child: MaterialApp.router(
        title: 'Scoreboard Backoffice',
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
        routerConfig: createRouter(repository, auth: auth),
      ),
    );
  }
}
