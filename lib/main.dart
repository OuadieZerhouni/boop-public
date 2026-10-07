import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/app_services.dart';
import 'core/debug_flags.dart';
import 'core/screenshot_scene.dart';
import 'core/settings.dart';
import 'l10n/app_localizations.dart';
import 'ui/home_shell.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final services = await AppServices.create();
  if (DebugFlags.resetFirstRun) await services.resetProgress();
  if (debugScene != null) services.progress.debugReplace(playedProgress(DateTime.now()));
  runApp(BoopApp(services: services));
}

class BoopApp extends StatelessWidget {
  const BoopApp({super.key, required this.services});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      services: services,
      child: ValueListenableBuilder<AppSettings>(
        valueListenable: services.settings,
        builder: (context, s, _) {
          final forced = s.languageCode == null ? null : Locale(s.languageCode!);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            locale: forced,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            // Theme depends on the resolved locale (Arabic uses its own face).
            builder: (context, child) {
              final locale = Localizations.localeOf(context);
              return Theme(data: buildTheme(locale), child: child!);
            },
            theme: buildTheme(forced ?? const Locale('en')),
            home: const HomeShell(),
          );
        },
      ),
    );
  }
}
