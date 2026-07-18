import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/auth/domain/entities/app_user.dart';

/// Contract for authentication operations. The domain layer depends
/// only on this interface — never on Supabase directly.
abstract class AuthRepository {
  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
    required String fullName,
    required String businessName,
  });

  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  });

  Future<Result<void>> signOut();

  Future<AppUser?> getCurrentUser();

  Stream<AppUser?> authStateChanges();
}
