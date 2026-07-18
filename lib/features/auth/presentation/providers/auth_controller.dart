import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/errors/failures.dart';
import 'package:traqio/features/auth/domain/entities/app_user.dart';
import 'package:traqio/features/auth/presentation/providers/auth_providers.dart';

/// Represents the state of an in-progress or completed auth action
/// (sign in / sign up). The UI reacts to this to show loading
/// spinners or error messages.
sealed class AuthActionState {
  const AuthActionState();
}

class AuthActionInitial extends AuthActionState {
  const AuthActionInitial();
}

class AuthActionLoading extends AuthActionState {
  const AuthActionLoading();
}

class AuthActionSuccess extends AuthActionState {
  final AppUser user;
  const AuthActionSuccess(this.user);
}

class AuthActionError extends AuthActionState {
  final Failure failure;
  const AuthActionError(this.failure);
}

/// Controller that drives sign-in/sign-up screens. Kept separate
/// from authStateChangesProvider (which reflects the *actual*
/// session) so we can show form-level loading/error feedback.
class AuthController extends StateNotifier<AuthActionState> {
  final Ref ref;
  AuthController(this.ref) : super(const AuthActionInitial());

  Future<void> signIn({required String email, required String password}) async {
    state = const AuthActionLoading();
    final useCase = ref.read(signInUseCaseProvider);
    final result = await useCase(email: email, password: password);

    result.match(
      (failure) => state = AuthActionError(failure),
      (user) => state = AuthActionSuccess(user),
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String businessName,
  }) async {
    state = const AuthActionLoading();
    final useCase = ref.read(signUpUseCaseProvider);
    final result = await useCase(
      email: email,
      password: password,
      fullName: fullName,
      businessName: businessName,
    );

    result.match(
      (failure) => state = AuthActionError(failure),
      (user) => state = AuthActionSuccess(user),
    );
  }

  Future<void> signOut() async {
    state = const AuthActionLoading();
    final useCase = ref.read(signOutUseCaseProvider);
    final result = await useCase();

    result.match(
      (failure) => state = AuthActionError(failure),
      (_) => state = const AuthActionInitial(),
    );
  }

  void reset() {
    state = const AuthActionInitial();
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthActionState>((ref) {
  return AuthController(ref);
});
