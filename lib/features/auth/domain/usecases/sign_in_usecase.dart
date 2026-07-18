import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/auth/domain/entities/app_user.dart';
import 'package:traqio/features/auth/domain/repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;
  const SignInUseCase(this.repository);

  Future<Result<AppUser>> call({
    required String email,
    required String password,
  }) {
    return repository.signIn(email: email, password: password);
  }
}
