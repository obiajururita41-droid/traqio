enum InvoiceStatus { draft, sent, partiallyPaid, paid, overdue, cancelled }

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
