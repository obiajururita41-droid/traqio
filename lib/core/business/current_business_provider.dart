import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/business/business.dart';
import 'package:traqio/core/config/supabase_config.dart';

/// Resolves the business the signed-in user is currently acting as.
/// Until Feature 1 (multi-user accounts UI) ships, this simply picks
/// the user's first active membership — identical in effect to the
/// old "business_id = auth.uid()" behavior for every existing
/// single-business account, since signup creates exactly one.
final currentBusinessProvider = FutureProvider<Business?>((ref) async {
  final client = SupabaseConfig.client;
  final userId = client.auth.currentUser?.id;
  if (userId == null) return null;

  final rows = await client
      .from('business_members')
      .select('business_id, role, businesses(id, name, currency, owner_id)')
      .eq('user_id', userId)
      .eq('status', 'active')
      .order('joined_at', ascending: true)
      .limit(1);

  if (rows.isEmpty) return null;

  final row = rows.first;
  final businessJoin = row['businesses'] as Map<String, dynamic>;

  return Business(
    id: businessJoin['id'] as String,
    name: businessJoin['name'] as String,
    currency: businessJoin['currency'] as String,
    ownerId: businessJoin['owner_id'] as String,
    myRole: MemberRoleX.fromDb(row['role'] as String),
  );
});

/// Convenience provider every datasource will use — throws if somehow
/// called before a business exists, which should never happen for an
/// authenticated user given signup always creates one.
final currentBusinessIdProvider = Provider<String>((ref) {
  final business = ref.watch(currentBusinessProvider).valueOrNull;
  if (business == null) {
    throw StateError('No active business found for the current user.');
  }
  return business.id;
});
