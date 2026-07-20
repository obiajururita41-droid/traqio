enum InvoiceStatus { draft, sent, partiallyPaid, paid, overdue, cancelled }
enum PaymentMethod { cash, bankTransfer, card, mobileMoney, other }

extension InvoiceStatusX on InvoiceStatus {
  String get dbValue {
    switch (this) {
      case InvoiceStatus.draft: return 'draft';
      case InvoiceStatus.sent: return 'sent';
      case InvoiceStatus.partiallyPaid: return 'partially_paid';
      case InvoiceStatus.paid: return 'paid';
      case InvoiceStatus.overdue: return 'overdue';
      case InvoiceStatus.cancelled: return 'cancelled';
    }
  }

  String get label {
    switch (this) {
      case InvoiceStatus.draft: return 'Draft';
      case InvoiceStatus.sent: return 'Sent';
      case InvoiceStatus.partiallyPaid: return 'Partially Paid';
      case InvoiceStatus.paid: return 'Paid';
      case InvoiceStatus.overdue: return 'Overdue';
      case InvoiceStatus.cancelled: return 'Cancelled';
    }
  }

  static InvoiceStatus fromDb(String value) {
    switch (value) {
      case 'draft': return InvoiceStatus.draft;
      case 'sent': return InvoiceStatus.sent;
      case 'partially_paid': return InvoiceStatus.partiallyPaid;
      case 'paid': return InvoiceStatus.paid;
      case 'overdue': return InvoiceStatus.overdue;
      case 'cancelled': return InvoiceStatus.cancelled;
      default: return InvoiceStatus.draft;
    }
  }
}

extension PaymentMethodX on PaymentMethod {
  String get dbValue {
    switch (this) {
      case PaymentMethod.cash: return 'cash';
      case PaymentMethod.bankTransfer: return 'bank_transfer';
      case PaymentMethod.card: return 'card';
      case PaymentMethod.mobileMoney: return 'mobile_money';
      case PaymentMethod.other: return 'other';
    }
  }

  String get label {
    switch (this) {
      case PaymentMethod.cash: return 'Cash';
      case PaymentMethod.bankTransfer: return 'Bank Transfer';
      case PaymentMethod.card: return 'Card';
      case PaymentMethod.mobileMoney: return 'Mobile Money';
      case PaymentMethod.other: return 'Other';
    }
  }

  static PaymentMethod? fromDb(String? value) {
    switch (value) {
      case 'cash': return PaymentMethod.cash;
      case 'bank_transfer': return PaymentMethod.bankTransfer;
      case 'card': return PaymentMethod.card;
      case 'mobile_money': return PaymentMethod.mobileMoney;
      case 'other': return PaymentMethod.other;
      default: return null;
    }
  }
}
