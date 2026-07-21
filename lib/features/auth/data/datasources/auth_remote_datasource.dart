import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:traqio/core/errors/exceptions.dart';
import 'package:traqio/features/auth/data/models/user_model.dart';

/// Talks directly to Supabase. Throws exceptions on failure —
/// the repository layer is responsible for catching and converting
/// these into Failures.
class AuthRemoteDataSource {
  final SupabaseClient client;
  const AuthRemoteDataSource(this.client);

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
    required String businessName,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw AuthException('Sign up failed: no user returned.');
      }

      await client.from('profiles').insert({
        'id': user.id,
        'email': email,
        'full_name': fullName,
        'business_name': businessName,
        'role': 'owner',
      });

      // Every signup creates its own business, with the signing-up
      // user as its owner member. This is the foundation for
      // multi-user accounts (Feature 1) — a business is a first-class
      // entity from day one, not implicitly "whoever signed up."
      await client.from('businesses').insert({
        'id': user.id,
        'name': businessName,
        'owner_id': user.id,
      });

      await client.from('business_members').insert({
        'business_id': user.id,
        'user_id': user.id,
        'role': 'owner',
        'status': 'active',
        'joined_at': DateTime.now().toIso8601String(),
      });

      return UserModel(
        id: user.id,
        email: email,
        fullName: fullName,
        businessName: businessName,
        role: 'owner',
      );
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw AuthException('Sign in failed: invalid credentials.');
      }

      final profile = await client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson(profile);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  Future<UserModel?> getCurrentUser() async {
    final user = client.auth.currentUser;
    if (user == null) return null;

    try {
      final profile = await client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson(profile);
    } catch (e) {
      return null;
    }
  }

  Stream<UserModel?> authStateChanges() {
    return client.auth.onAuthStateChange.asyncMap((state) async {
      final user = state.session?.user;
      if (user == null) return null;

      try {
        final profile = await client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();
        return UserModel.fromJson(profile);
      } catch (e) {
        return null;
      }
    });
  }
}
