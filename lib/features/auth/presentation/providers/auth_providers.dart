import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:traqio/core/config/supabase_config.dart';
import 'package:traqio/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:traqio/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:traqio/features/auth/domain/entities/app_user.dart';
import 'package:traqio/features/auth/domain/repositories/auth_repository.dart';
import 'package:traqio/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:traqio/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:traqio/features/auth/domain/usecases/sign_up_usecase.dart';

/// Wires the dependency chain: Supabase client -> datasource ->
/// repository -> use cases. Every layer is swappable in tests by
/// overriding these providers.

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return SupabaseConfig.client;
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(supabaseClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(ref.watch(authRepositoryProvider));
});

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

/// Streams the current auth state — screens/router can watch this
/// to reactively show login vs dashboard.
final authStateChangesProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});
