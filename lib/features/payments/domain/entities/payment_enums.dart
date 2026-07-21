enum PaymentType { customerReceipt, supplierPayment, refund, adjustment }

extension PaymentTypeX on PaymentType {
  String get dbValue {
    switch (this) {
      case PaymentType.customerReceipt: return 'customer_receipt';
      case PaymentType.supplierPayment: return 'supplier_payment';
      case PaymentType.refund: return 'refund';
      case PaymentType.adjustment: return 'adjustment';
    }
  }

  String get label {
    switch (this) {
      case PaymentType.customerReceipt: return 'Customer Receipt';
      case PaymentType.supplierPayment: return 'Supplier Payment';
      case PaymentType.refund: return 'Refund';
      case PaymentType.adjustment: return 'Adjustment';
    }
  }

  static PaymentType fromDb(String value) {
    switch (value) {
      case 'customer_receipt': return PaymentType.customerReceipt;
      case 'supplier_payment': return PaymentType.supplierPayment;
      case 'refund': return PaymentType.refund;
      default: return PaymentType.adjustment;
    }
  }
}
