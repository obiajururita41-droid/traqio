enum SalesOrderStatus { draft, confirmed, partiallyFulfilled, fulfilled, cancelled }

extension SalesOrderStatusX on SalesOrderStatus {
  String get dbValue {
    switch (this) {
      case SalesOrderStatus.draft: return 'draft';
      case SalesOrderStatus.confirmed: return 'confirmed';
      case SalesOrderStatus.partiallyFulfilled: return 'partially_fulfilled';
      case SalesOrderStatus.fulfilled: return 'fulfilled';
      case SalesOrderStatus.cancelled: return 'cancelled';
    }
  }

  String get label {
    switch (this) {
      case SalesOrderStatus.draft: return 'Draft';
      case SalesOrderStatus.confirmed: return 'Confirmed';
      case SalesOrderStatus.partiallyFulfilled: return 'Partially Fulfilled';
      case SalesOrderStatus.fulfilled: return 'Fulfilled';
      case SalesOrderStatus.cancelled: return 'Cancelled';
    }
  }

  static SalesOrderStatus fromDb(String value) {
    switch (value) {
      case 'draft': return SalesOrderStatus.draft;
      case 'confirmed': return SalesOrderStatus.confirmed;
      case 'partially_fulfilled': return SalesOrderStatus.partiallyFulfilled;
      case 'fulfilled': return SalesOrderStatus.fulfilled;
      case 'cancelled': return SalesOrderStatus.cancelled;
      default: return SalesOrderStatus.draft;
    }
  }
}
