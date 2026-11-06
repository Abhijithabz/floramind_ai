import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_state.dart';
import 'l10n/app_strings.dart';
import 'screens/community/community_feed_screen.dart';
import 'screens/community/create_community_post_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

class FloraMindApp extends StatefulWidget {
  const FloraMindApp({super.key});

  @override
  State<FloraMindApp> createState() => _FloraMindAppState();
}

class _FloraMindAppState extends State<FloraMindApp> {
  final FloraMindAppState _appState = FloraMindAppState();

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FloraMindAppScope(
      state: _appState,
      child: AnimatedBuilder(
        animation: _appState,
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            onGenerateTitle: (context) => AppStrings.of(context).appTitle,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: _appState.themeMode,
            locale: _appState.locale,
            supportedLocales: AppStrings.supportedLocales,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const SplashScreen(),
            routes: {
              CommunityFeedScreen.routeName: (_) => const CommunityFeedScreen(),
              '/community/create': (_) => const CreateCommunityPostScreen(),
            },
          );
        },
      ),
    );
  }
}
