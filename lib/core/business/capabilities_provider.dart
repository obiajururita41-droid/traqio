import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/business/current_business_provider.dart';
import 'package:traqio/core/config/supabase_config.dart';

/// The set of capability keys the current user has for their active
/// business. UI checks membership in this set rather than checking
/// role directly — this is what lets new roles (e.g. "Accountant")
/// be introduced later purely via database rows, with zero Dart
/// changes to any screen that already checks a capability correctly.
final myCapabilitiesProvider = FutureProvider<Set<String>>((ref) async {
  final businessId = ref.watch(currentBusinessIdProvider);
  final client = SupabaseConfig.client;

  final userId = client.auth.currentUser?.id;
  if (userId == null) return {};

  final memberRows = await client
      .from('business_members')
      .select('role')
      .eq('business_id', businessId)
      .eq('user_id', userId)
      .eq('status', 'active')
      .limit(1);

  if (memberRows.isEmpty) return {};

  final role = memberRows.first['role'] as String;

  final capabilityRows = await client
      .from('role_capabilities')
      .select('capability_key')
      .eq('role', role);

  return (capabilityRows as List)
      .map((row) => row['capability_key'] as String)
      .toSet();
});

/// Convenience helper — widgets can do:
/// `ref.watch(hasCapabilityProvider(Capability.manageMembers))`
final hasCapabilityProvider = Provider.family<bool, String>((ref, capability) {
  final capabilities = ref.watch(myCapabilitiesProvider).valueOrNull ?? {};
  return capabilities.contains(capability);
});
