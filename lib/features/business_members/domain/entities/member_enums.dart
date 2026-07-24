enum MemberStatus { active, invited, removed }

extension MemberStatusX on MemberStatus {
  String get dbValue => name;
  String get label {
    switch (this) {
      case MemberStatus.active: return 'Active';
      case MemberStatus.invited: return 'Invited';
      case MemberStatus.removed: return 'Removed';
    }
  }

  static MemberStatus fromDb(String value) =>
      MemberStatus.values.firstWhere((s) => s.dbValue == value, orElse: () => MemberStatus.invited);
}
