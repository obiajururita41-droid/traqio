import 'package:traqio/core/business/business.dart';
import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/business_members/domain/entities/business_member.dart';

abstract class BusinessMemberRepository {
  Future<Result<List<BusinessMember>>> getMembers(String businessId);

  Future<Result<BusinessMember>> inviteMember({
    required String businessId,
    required String email,
    required MemberRole role,
  });

  Future<Result<BusinessMember>> updateMemberRole({
    required String businessId,
    required String memberId,
    required MemberRole newRole,
  });

  Future<Result<BusinessMember>> removeMember({
    required String businessId,
    required String memberId,
  });

  /// Called right after signup/login to link any pending invites
  /// matching the current user's email to their account.
  Future<Result<void>> attachPendingInvites();
}
