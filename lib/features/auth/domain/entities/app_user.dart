import 'package:equatable/equatable.dart';

/// Domain entity representing an authenticated Traqio user.
/// This is deliberately independent of Supabase's User model —
/// domain layer never knows about the backend.
class AppUser extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final String? businessName;
  final String role;

  const AppUser({
    required this.id,
    required this.email,
    this.fullName,
    this.businessName,
    this.role = 'owner',
  });

  @override
  List<Object?> get props => [id, email, fullName, businessName, role];
}
