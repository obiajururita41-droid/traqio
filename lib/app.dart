import 'package:flutter/material.dart';
import 'package:traqio/core/theme/app_theme.dart';

/// Root widget. Will be upgraded to MaterialApp.router
/// once GoRouter is wired in a future step.
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
      home: const _ThemePreviewScreen(),
    );
  }
}

/// Temporary screen to visually verify the theme system.
/// Will be replaced by the real Dashboard in a later step.
class _ThemePreviewScreen extends StatelessWidget {
  const _ThemePreviewScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Traqio Theme Preview')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Headline', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text('Body text example', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('This is a themed card', style: Theme.of(context).textTheme.bodyMedium),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: const Text('Primary Button')),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: () {}, child: const Text('Secondary Button')),
            const SizedBox(height: 20),
            const TextField(decoration: InputDecoration(hintText: 'Input field')),
          ],
        ),
      ),
    );
  }
}
