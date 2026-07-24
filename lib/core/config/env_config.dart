import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get supabaseUrl {
    final url = dotenv.env['SUPABASE_URL'] ?? '';
    debugPrint('SUPABASE_URL = $url');
    return url;
  }

  static String get supabaseAnonKey {
    final key = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    debugPrint('SUPABASE_ANON_KEY loaded = ${key.isNotEmpty}');
    return key;
  }

  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
    debugPrint('dotenv loaded');
  }
}
