import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/business/current_business_provider.dart';
import 'package:traqio/core/config/supabase_config.dart';
import 'package:traqio/features/business_members/data/datasources/business_member_remote_datasource.dart';
import 'package:traqio/features/business_members/data/repositories/business_member_repository_impl.dart';
import 'package:traqio/features/business_members/domain/entities/business_member.dart';
import 'package:traqio/features/business_members/domain/repositories/business_member_repository.dart';
import 'package:traqio/features/business_members/domain/usecases/business_member_usecases.dart';

final businessMemberRemoteDataSourceProvider = Provider<BusinessMemberRemoteDataSource>((ref) {
  return BusinessMemberRemoteDataSource(SupabaseConfig.client);
});

final businessMemberRepositoryProvider = Provider<BusinessMemberRepository>((ref) {
  return BusinessMemberRepositoryImpl(ref.watch(businessMemberRemoteDataSourceProvider));
});

final getMembersUseCaseProvider = Provider((ref) {
  return GetMembersUseCase(ref.watch(businessMemberRepositoryProvider));
});

final inviteMemberUseCaseProvider = Provider((ref) {
  return InviteMemberUseCase(ref.watch(businessMemberRepositoryProvider));
});

final updateMemberRoleUseCaseProvider = Provider((ref) {
  return UpdateMemberRoleUseCase(ref.watch(businessMemberRepositoryProvider));
});

final removeMemberUseCaseProvider = Provider((ref) {
  return RemoveMemberUseCase(ref.watch(businessMemberRepositoryProvider));
});

final attachPendingInvitesUseCaseProvider = Provider((ref) {
  return AttachPendingInvitesUseCase(ref.watch(businessMemberRepositoryProvider));
});

final businessMembersProvider = FutureProvider<List<BusinessMember>>((ref) async {
  final businessId = ref.watch(currentBusinessIdProvider);
  final result = await ref.watch(getMembersUseCaseProvider)(businessId);
  return result.match((failure) => throw failure, (data) => data);
});
