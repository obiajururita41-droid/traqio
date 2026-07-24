import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:traqio/core/business/business.dart';
import 'package:traqio/core/errors/exceptions.dart';
import 'package:traqio/features/business_members/data/models/business_member_model.dart';

class BusinessMemberRemoteDataSource {
  final SupabaseClient client;
  const BusinessMemberRemoteDataSource(this.client);

  static const _table = 'business_members';
  // profiles has no FK-declared relationship to business_members in
  // Postgres (user_id references auth.users, not public.profiles
  // directly), so we fetch profiles separately rather than relying
  // on a Supabase embedded join here.
  static const _select = '*';

  Future<List<BusinessMemberModel>> getMembers(String businessId) async {
    try {
      final rows = await client
          .from(_table)
          .select(_select)
          .eq('business_id', businessId)
          .neq('status', 'removed')
          .order('created_at', ascending: true);

      final members = (rows as List).cast<Map<String, dynamic>>();

      final userIds = members
          .map((m) => m['user_id'] as String?)
          .whereType<String>()
          .toList();

      Map<String, Map<String, dynamic>> profilesById = {};
      if (userIds.isNotEmpty) {
        final profileRows = await client
            .from('profiles')
            .select('id, full_name, email')
            .inFilter('id', userIds);
        for (final row in (profileRows as List).cast<Map<String, dynamic>>()) {
          profilesById[row['id'] as String] = row;
        }
      }

      return members.map((m) {
        final userId = m['user_id'] as String?;
        final profile = userId != null ? profilesById[userId] : null;
        final merged = {...m, if (profile != null) 'profiles': profile};
        return BusinessMemberModel.fromJson(merged);
      }).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<BusinessMemberModel> inviteMember({
    required String businessId,
    required String email,
    required MemberRole role,
  }) async {
    try {
      final row = await client.rpc('invite_member', params: {
        'p_business_id': businessId,
        'p_email': email,
        'p_role': role.dbValue,
      });
      return BusinessMemberModel.fromJson(row as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<BusinessMemberModel> updateMemberRole({
    required String businessId,
    required String memberId,
    required MemberRole newRole,
  }) async {
    try {
      final row = await client.rpc('update_member_role', params: {
        'p_business_id': businessId,
        'p_member_id': memberId,
        'p_new_role': newRole.dbValue,
      });
      return BusinessMemberModel.fromJson(row as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<BusinessMemberModel> removeMember({
    required String businessId,
    required String memberId,
  }) async {
    try {
      final row = await client.rpc('remove_member', params: {
        'p_business_id': businessId,
        'p_member_id': memberId,
      });
      return BusinessMemberModel.fromJson(row as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> attachPendingInvites() async {
    try {
      await client.rpc('attach_pending_invites');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
