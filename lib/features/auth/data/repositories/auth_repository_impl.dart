import 'package:traqio/core/errors/exceptions.dart';
import 'package:traqio/core/errors/failures.dart';
import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:traqio/features/auth/domain/entities/app_user.dart';
import 'package:traqio/features/auth/domain/repositories/auth_repository.dart';

/// Implements the domain's AuthRepository contract using Supabase.
/// Converts exceptions (thrown by the datasource) into Failures
/// (returned to the domain/presentation layers) — this is the
/// boundary where "throws" becomes "returns Either".
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  const AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
    required String fullName,
    required String businessName,
  }) async {
    try {
      final user = await remoteDataSource.signUp(
        email: email,
        password: password,
        fullName: fullName,
        businessName: businessName,
      );
      return Result.right(user);
    } on AuthException catch (e) {
      return Result.left(AuthFailure(e.message));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.signIn(
        email: email,
        password: password,
      );
      return Result.right(user);
    } on AuthException catch (e) {
      return Result.left(AuthFailure(e.message));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return Result.right(null);
    } on AuthException catch (e) {
      return Result.left(AuthFailure(e.message));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<AppUser?> getCurrentUser() {
    return remoteDataSource.getCurrentUser();
  }

  @override
  Stream<AppUser?> authStateChanges() {
    return remoteDataSource.authStateChanges();
  }
}
