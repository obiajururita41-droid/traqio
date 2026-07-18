import 'package:flutter/material.dart';

/// Temporary root widget. Will be replaced with MaterialApp.router
/// once GoRouter is wired in the Theme + Routing step.
class TraqioApp extends StatelessWidget {
  const TraqioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text(
            'Traqio — Setup Complete ✅',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
