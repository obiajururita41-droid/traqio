import 'package:flutter/material.dart';
import 'package:traqio/core/theme/app_theme.dart';
import 'package:traqio/features/auth/presentation/screens/sign_in_screen.dart';

class TraqioApp extends StatelessWidget {
  const TraqioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Traqio',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const SignInScreen(),
    );
  }
}
