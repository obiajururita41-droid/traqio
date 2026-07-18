enum CustomerType { retail, wholesale, vip }
enum CustomerStatus { active, inactive }
enum LedgerEntryType { sale, payment, creditNote, adjustment, openingBalance }
enum LedgerDirection { debit, credit }

extension CustomerTypeX on CustomerType {
  String get dbValue => name;
  String get label {
    switch (this) {
      case CustomerType.retail: return 'Retail';
      case CustomerType.wholesale: return 'Wholesale';
      case CustomerType.vip: return 'VIP';
    }
  }

  static CustomerType fromDb(String value) =>
      CustomerType.values.firstWhere((t) => t.dbValue == value, orElse: () => CustomerType.retail);
}

extension CustomerStatusX on CustomerStatus {
  String get dbValue => name;
  static CustomerStatus fromDb(String value) =>
      CustomerStatus.values.firstWhere((s) => s.dbValue == value, orElse: () => CustomerStatus.active);
}

extension LedgerEntryTypeX on LedgerEntryType {
  String get dbValue {
    switch (this) {
      case LedgerEntryType.sale: return 'sale';
      case LedgerEntryType.payment: return 'payment';
      case LedgerEntryType.creditNote: return 'credit_note';
      case LedgerEntryType.adjustment: return 'adjustment';
      case LedgerEntryType.openingBalance: return 'opening_balance';
    }
  }

  String get label {
    switch (this) {
      case LedgerEntryType.sale: return 'Sale';
      case LedgerEntryType.payment: return 'Payment';
      case LedgerEntryType.creditNote: return 'Credit Note';
      case LedgerEntryType.adjustment: return 'Adjustment';
      case LedgerEntryType.openingBalance: return 'Opening Balance';
    }
  }

  static LedgerEntryType fromDb(String value) {
    switch (value) {
      case 'sale': return LedgerEntryType.sale;
      case 'payment': return LedgerEntryType.payment;
      case 'credit_note': return LedgerEntryType.creditNote;
      case 'opening_balance': return LedgerEntryType.openingBalance;
      default: return LedgerEntryType.adjustment;
    }
  }
}

extension LedgerDirectionX on LedgerDirection {
  String get dbValue => name;
  static LedgerDirection fromDb(String value) =>
      value == 'debit' ? LedgerDirection.debit : LedgerDirection.credit;
}
