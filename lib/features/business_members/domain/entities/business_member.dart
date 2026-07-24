import 'package:equatable/equatable.dart';
import 'package:traqio/core/business/business.dart';
import 'package:traqio/features/business_members/domain/entities/member_enums.dart';

class BusinessMember extends Equatable {
  final String id;
  final String businessId;
  final String? userId;
  final String? invitedEmail;
  final String? displayName;
  final String? displayEmail;
  final MemberRole role;
  final MemberStatus status;
  final DateTime? joinedAt;
  final DateTime createdAt;

  const BusinessMember({
    required this.id,
    required this.businessId,
    this.userId,
    this.invitedEmail,
    this.displayName,
    this.displayEmail,
    required this.role,
    required this.status,
    this.joinedAt,
    required this.createdAt,
  });

  bool get isPending => status == MemberStatus.invited;
  bool get isOwner => role == MemberRole.owner;

  String get nameOrEmail => displayName ?? displayEmail ?? invitedEmail ?? 'Unknown';

  @override
  List<Object?> get props => [
        id, businessId, userId, invitedEmail, displayName, displayEmail,
        role, status, joinedAt, createdAt,
      ];
}
