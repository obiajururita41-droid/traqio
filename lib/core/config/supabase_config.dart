import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:traqio/core/config/env_config.dart';

/// Initializes and exposes the Supabase client singleton.
class SupabaseConfig {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      publishableKey: EnvConfig.supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
