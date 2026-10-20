import 'package:flutter/material.dart';

import 'screens/main_navigation_screen.dart';
import 'theme/app_theme.dart';

class TabunginApp extends StatelessWidget {
  const TabunginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tabungin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationScreen(),
    );
  }
}
