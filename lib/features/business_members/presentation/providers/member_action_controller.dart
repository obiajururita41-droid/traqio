import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/business/business.dart';
import 'package:traqio/core/business/current_business_provider.dart';
import 'package:traqio/core/errors/failures.dart';
import 'package:traqio/features/business_members/domain/entities/business_member.dart';
import 'package:traqio/features/business_members/presentation/providers/business_member_providers.dart';

sealed class MemberActionState {
  const MemberActionState();
}

class MemberActionInitial extends MemberActionState {
  const MemberActionInitial();
}

class MemberActionLoading extends MemberActionState {
  const MemberActionLoading();
}

class MemberActionSuccess extends MemberActionState {
  final BusinessMember member;
  const MemberActionSuccess(this.member);
}

class MemberActionError extends MemberActionState {
  final Failure failure;
  const MemberActionError(this.failure);
}

class MemberActionController extends StateNotifier<MemberActionState> {
  final Ref ref;
  MemberActionController(this.ref) : super(const MemberActionInitial());

  Future<void> invite({required String email, required MemberRole role}) async {
    state = const MemberActionLoading();
    final businessId = ref.read(currentBusinessIdProvider);
    final useCase = ref.read(inviteMemberUseCaseProvider);
    final result = await useCase(businessId: businessId, email: email, role: role);
    result.match(
      (failure) => state = MemberActionError(failure),
      (member) {
        state = MemberActionSuccess(member);
        ref.invalidate(businessMembersProvider);
      },
    );
  }

  Future<void> updateRole({required String memberId, required MemberRole newRole}) async {
    state = const MemberActionLoading();
    final businessId = ref.read(currentBusinessIdProvider);
    final useCase = ref.read(updateMemberRoleUseCaseProvider);
    final result = await useCase(businessId: businessId, memberId: memberId, newRole: newRole);
    result.match(
      (failure) => state = MemberActionError(failure),
      (member) {
        state = MemberActionSuccess(member);
        ref.invalidate(businessMembersProvider);
      },
    );
  }

  Future<void> remove(String memberId) async {
    state = const MemberActionLoading();
    final businessId = ref.read(currentBusinessIdProvider);
    final useCase = ref.read(removeMemberUseCaseProvider);
    final result = await useCase(businessId: businessId, memberId: memberId);
    result.match(
      (failure) => state = MemberActionError(failure),
      (member) {
        state = MemberActionSuccess(member);
        ref.invalidate(businessMembersProvider);
      },
    );
  }

  void reset() => state = const MemberActionInitial();
}

final memberActionControllerProvider =
    StateNotifierProvider<MemberActionController, MemberActionState>((ref) {
  return MemberActionController(ref);
});
