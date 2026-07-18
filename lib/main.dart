import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/config/env_config.dart';
import 'package:traqio/core/config/supabase_config.dart';
import 'package:traqio/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EnvConfig.load();
  await SupabaseConfig.initialize();

  runApp(const ProviderScope(child: TraqioApp()));
}
