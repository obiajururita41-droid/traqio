import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:traqio/core/config/env_config.dart';

class SupabaseConfig {
  static Future<void> initialize() async {
    debugPrint('URL: ${EnvConfig.supabaseUrl}');
    debugPrint('Key loaded: ${EnvConfig.supabaseAnonKey.isNotEmpty}');

    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      publishableKey: EnvConfig.supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
