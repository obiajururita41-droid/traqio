import 'package:traqio/core/business/business.dart';
import 'package:traqio/core/errors/failures.dart';
import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/business_members/data/datasources/business_member_remote_datasource.dart';
import 'package:traqio/features/business_members/domain/entities/business_member.dart';
import 'package:traqio/features/business_members/domain/repositories/business_member_repository.dart';

class BusinessMemberRepositoryImpl implements BusinessMemberRepository {
  final BusinessMemberRemoteDataSource remoteDataSource;
  const BusinessMemberRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<BusinessMember>>> getMembers(String businessId) async {
    try {
      return Result.right(await remoteDataSource.getMembers(businessId));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<BusinessMember>> inviteMember({
    required String businessId,
    required String email,
    required MemberRole role,
  }) async {
    try {
      final member = await remoteDataSource.inviteMember(
        businessId: businessId,
        email: email,
        role: role,
      );
      return Result.right(member);
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<BusinessMember>> updateMemberRole({
    required String businessId,
    required String memberId,
    required MemberRole newRole,
  }) async {
    try {
      final member = await remoteDataSource.updateMemberRole(
        businessId: businessId,
        memberId: memberId,
        newRole: newRole,
      );
      return Result.right(member);
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<BusinessMember>> removeMember({
    required String businessId,
    required String memberId,
  }) async {
    try {
      final member = await remoteDataSource.removeMember(
        businessId: businessId,
        memberId: memberId,
      );
      return Result.right(member);
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> attachPendingInvites() async {
    try {
      await remoteDataSource.attachPendingInvites();
      return Result.right(null);
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }
}
