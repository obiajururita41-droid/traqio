import 'package:equatable/equatable.dart';

enum MemberRole { owner, admin, staff }

extension MemberRoleX on MemberRole {
  String get dbValue => name;
  static MemberRole fromDb(String value) =>
      MemberRole.values.firstWhere((r) => r.dbValue == value, orElse: () => MemberRole.staff);
}

class Business extends Equatable {
  final String id;
  final String name;
  final String currency;
  final String ownerId;
  final MemberRole myRole;

  const Business({
    required this.id,
    required this.name,
    required this.currency,
    required this.ownerId,
    required this.myRole,
  });

  @override
  List<Object?> get props => [id, name, currency, ownerId, myRole];
}
