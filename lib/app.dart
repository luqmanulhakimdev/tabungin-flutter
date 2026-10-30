import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/main_navigation_screen.dart';
import 'theme/app_theme.dart';

class TabunginApp extends StatelessWidget {
  const TabunginApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider?>();
    final localeProvider = context.watch<LocaleProvider?>();

    return MaterialApp(
      title: 'Tabungin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider?.themeMode ?? ThemeMode.system,
      locale: localeProvider?.locale ?? const Locale('id'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id'),
        Locale('en'),
      ],
      home: const MainNavigationScreen(),
    );
  }
}
