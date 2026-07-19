enum PurchaseOrderStatus { draft, sent, partiallyReceived, received, cancelled }

extension PurchaseOrderStatusX on PurchaseOrderStatus {
  String get dbValue {
    switch (this) {
      case PurchaseOrderStatus.draft: return 'draft';
      case PurchaseOrderStatus.sent: return 'sent';
      case PurchaseOrderStatus.partiallyReceived: return 'partially_received';
      case PurchaseOrderStatus.received: return 'received';
      case PurchaseOrderStatus.cancelled: return 'cancelled';
    }
  }

  String get label {
    switch (this) {
      case PurchaseOrderStatus.draft: return 'Draft';
      case PurchaseOrderStatus.sent: return 'Sent';
      case PurchaseOrderStatus.partiallyReceived: return 'Partially Received';
      case PurchaseOrderStatus.received: return 'Received';
      case PurchaseOrderStatus.cancelled: return 'Cancelled';
    }
  }

  static PurchaseOrderStatus fromDb(String value) {
    switch (value) {
      case 'draft': return PurchaseOrderStatus.draft;
      case 'sent': return PurchaseOrderStatus.sent;
      case 'partially_received': return PurchaseOrderStatus.partiallyReceived;
      case 'received': return PurchaseOrderStatus.received;
      case 'cancelled': return PurchaseOrderStatus.cancelled;
      default: return PurchaseOrderStatus.draft;
    }
  }
}
