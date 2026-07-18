import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized access to environment variables.
/// Never read dotenv.env[...] directly outside this file.
class EnvConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }
}
