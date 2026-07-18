enum SupplierType { local, international }
enum SupplierStatus { active, inactive }
enum SupplierLedgerEntryType { purchase, payment, debitNote, adjustment, openingBalance }
enum SupplierLedgerDirection { credit, debit }

extension SupplierTypeX on SupplierType {
  String get dbValue => name;
  String get label => this == SupplierType.local ? 'Local' : 'International';
  static SupplierType fromDb(String value) =>
      SupplierType.values.firstWhere((t) => t.dbValue == value, orElse: () => SupplierType.local);
}

extension SupplierStatusX on SupplierStatus {
  String get dbValue => name;
  static SupplierStatus fromDb(String value) =>
      SupplierStatus.values.firstWhere((s) => s.dbValue == value, orElse: () => SupplierStatus.active);
}

extension SupplierLedgerEntryTypeX on SupplierLedgerEntryType {
  String get dbValue {
    switch (this) {
      case SupplierLedgerEntryType.purchase: return 'purchase';
      case SupplierLedgerEntryType.payment: return 'payment';
      case SupplierLedgerEntryType.debitNote: return 'debit_note';
      case SupplierLedgerEntryType.adjustment: return 'adjustment';
      case SupplierLedgerEntryType.openingBalance: return 'opening_balance';
    }
  }

  String get label {
    switch (this) {
      case SupplierLedgerEntryType.purchase: return 'Purchase';
      case SupplierLedgerEntryType.payment: return 'Payment';
      case SupplierLedgerEntryType.debitNote: return 'Debit Note';
      case SupplierLedgerEntryType.adjustment: return 'Adjustment';
      case SupplierLedgerEntryType.openingBalance: return 'Opening Balance';
    }
  }

  static SupplierLedgerEntryType fromDb(String value) {
    switch (value) {
      case 'purchase': return SupplierLedgerEntryType.purchase;
      case 'payment': return SupplierLedgerEntryType.payment;
      case 'debit_note': return SupplierLedgerEntryType.debitNote;
      case 'opening_balance': return SupplierLedgerEntryType.openingBalance;
      default: return SupplierLedgerEntryType.adjustment;
    }
  }
}

extension SupplierLedgerDirectionX on SupplierLedgerDirection {
  String get dbValue => name;
  static SupplierLedgerDirection fromDb(String value) =>
      value == 'credit' ? SupplierLedgerDirection.credit : SupplierLedgerDirection.debit;
}
