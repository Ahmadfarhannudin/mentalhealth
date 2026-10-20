import 'package:flutter/material.dart';

import 'core/theme/app_background.dart';
import 'core/theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const TenangApp());
}

class TenangApp extends StatelessWidget {
  const TenangApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tenang',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light.copyWith(
        scaffoldBackgroundColor: Colors.transparent,
      ),
      builder: (context, child) =>
          AppBackground(child: child ?? const SizedBox()),
      home: const HomeScreen(),
    );
  }
}
