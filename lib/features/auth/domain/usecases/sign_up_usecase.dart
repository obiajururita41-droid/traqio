import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/auth/domain/entities/app_user.dart';
import 'package:traqio/features/auth/domain/repositories/auth_repository.dart';

/// Encapsulates the sign-up business operation.
/// Keeping this as its own class (rather than calling the repository
/// directly from the UI) makes the operation testable and reusable.
class SignUpUseCase {
  final AuthRepository repository;
  const SignUpUseCase(this.repository);

  Future<Result<AppUser>> call({
    required String email,
    required String password,
    required String fullName,
    required String businessName,
  }) {
    return repository.signUp(
      email: email,
      password: password,
      fullName: fullName,
      businessName: businessName,
    );
  }
}
