import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/theme/app_theme.dart';
import 'package:traqio/features/auth/presentation/providers/auth_providers.dart';
import 'package:traqio/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:traqio/features/dashboard/presentation/screens/dashboard_screen.dart';

/// Temporary auth gate: shows Dashboard if a session exists, otherwise
/// Sign In. Will be replaced by GoRouter-based navigation guards later.
class TraqioApp extends ConsumerWidget {
  const TraqioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Traqio',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: authState.when(
        data: (user) => user != null ? const DashboardScreen() : const SignInScreen(),
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, st) => const SignInScreen(),
      ),
    );
  }
}
