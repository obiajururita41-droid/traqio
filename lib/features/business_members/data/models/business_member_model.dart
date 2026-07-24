import 'package:traqio/core/business/business.dart';
import 'package:traqio/features/business_members/domain/entities/business_member.dart';
import 'package:traqio/features/business_members/domain/entities/member_enums.dart';

class BusinessMemberModel extends BusinessMember {
  const BusinessMemberModel({
    required super.id,
    required super.businessId,
    super.userId,
    super.invitedEmail,
    super.displayName,
    super.displayEmail,
    required super.role,
    required super.status,
    super.joinedAt,
    required super.createdAt,
  });

  factory BusinessMemberModel.fromJson(Map<String, dynamic> json) {
    String? displayName;
    String? displayEmail;
    final profileJoin = json['profiles'];
    if (profileJoin is Map<String, dynamic>) {
      displayName = profileJoin['full_name'] as String?;
      displayEmail = profileJoin['email'] as String?;
    }

    return BusinessMemberModel(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      userId: json['user_id'] as String?,
      invitedEmail: json['invited_email'] as String?,
      displayName: displayName,
      displayEmail: displayEmail,
      role: MemberRoleX.fromDb(json['role'] as String),
      status: MemberStatusX.fromDb(json['status'] as String),
      joinedAt: json['joined_at'] == null ? null : DateTime.parse(json['joined_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
