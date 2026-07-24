import 'package:traqio/core/business/business.dart';
import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/business_members/domain/entities/business_member.dart';
import 'package:traqio/features/business_members/domain/repositories/business_member_repository.dart';

class GetMembersUseCase {
  final BusinessMemberRepository repository;
  const GetMembersUseCase(this.repository);
  Future<Result<List<BusinessMember>>> call(String businessId) => repository.getMembers(businessId);
}

class InviteMemberUseCase {
  final BusinessMemberRepository repository;
  const InviteMemberUseCase(this.repository);
  Future<Result<BusinessMember>> call({
    required String businessId,
    required String email,
    required MemberRole role,
  }) {
    return repository.inviteMember(businessId: businessId, email: email, role: role);
  }
}

class UpdateMemberRoleUseCase {
  final BusinessMemberRepository repository;
  const UpdateMemberRoleUseCase(this.repository);
  Future<Result<BusinessMember>> call({
    required String businessId,
    required String memberId,
    required MemberRole newRole,
  }) {
    return repository.updateMemberRole(businessId: businessId, memberId: memberId, newRole: newRole);
  }
}

class RemoveMemberUseCase {
  final BusinessMemberRepository repository;
  const RemoveMemberUseCase(this.repository);
  Future<Result<BusinessMember>> call({
    required String businessId,
    required String memberId,
  }) {
    return repository.removeMember(businessId: businessId, memberId: memberId);
  }
}

class AttachPendingInvitesUseCase {
  final BusinessMemberRepository repository;
  const AttachPendingInvitesUseCase(this.repository);
  Future<Result<void>> call() => repository.attachPendingInvites();
}
