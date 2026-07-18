import 'package:traqio/features/auth/domain/entities/app_user.dart';

/// Data-layer model. Handles JSON <-> AppUser conversion.
/// This is the ONLY place that knows about Supabase's row shape.
class UserModel extends AppUser {
  const UserModel({
    required super.id,
    required super.email,
    super.fullName,
    super.businessName,
    super.role = 'owner',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      businessName: json['business_name'] as String?,
      role: json['role'] as String? ?? 'owner',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'business_name': businessName,
      'role': role,
    };
  }
}
