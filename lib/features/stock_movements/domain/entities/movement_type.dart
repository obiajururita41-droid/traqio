enum MovementType { stockIn, stockOut, adjustment, transfer, returnMovement, damaged, expired }

enum MovementDirection { increase, decrease }

enum ReferenceType { purchaseOrder, salesOrder, invoice, returnOrder, manual, transfer }

enum AdjustmentReason { theft, miscount, damage, expiry, correction, other }

extension MovementTypeX on MovementType {
  String get dbValue {
    switch (this) {
      case MovementType.stockIn: return 'stock_in';
      case MovementType.stockOut: return 'stock_out';
      case MovementType.adjustment: return 'adjustment';
      case MovementType.transfer: return 'transfer';
      case MovementType.returnMovement: return 'return';
      case MovementType.damaged: return 'damaged';
      case MovementType.expired: return 'expired';
    }
  }

  String get label {
    switch (this) {
      case MovementType.stockIn: return 'Stock In';
      case MovementType.stockOut: return 'Stock Out';
      case MovementType.adjustment: return 'Adjustment';
      case MovementType.transfer: return 'Transfer';
      case MovementType.returnMovement: return 'Return';
      case MovementType.damaged: return 'Damaged';
      case MovementType.expired: return 'Expired';
    }
  }

  static MovementType fromDb(String value) {
    switch (value) {
      case 'stock_in': return MovementType.stockIn;
      case 'stock_out': return MovementType.stockOut;
      case 'adjustment': return MovementType.adjustment;
      case 'transfer': return MovementType.transfer;
      case 'return': return MovementType.returnMovement;
      case 'damaged': return MovementType.damaged;
      case 'expired': return MovementType.expired;
      default: return MovementType.adjustment;
    }
  }
}

extension MovementDirectionX on MovementDirection {
  String get dbValue => this == MovementDirection.increase ? 'increase' : 'decrease';

  static MovementDirection fromDb(String value) =>
      value == 'increase' ? MovementDirection.increase : MovementDirection.decrease;
}

extension ReferenceTypeX on ReferenceType {
  String get dbValue {
    switch (this) {
      case ReferenceType.purchaseOrder: return 'purchase_order';
      case ReferenceType.salesOrder: return 'sales_order';
      case ReferenceType.invoice: return 'invoice';
      case ReferenceType.returnOrder: return 'return_order';
      case ReferenceType.manual: return 'manual';
      case ReferenceType.transfer: return 'transfer';
    }
  }

  static ReferenceType? fromDb(String? value) {
    switch (value) {
      case 'purchase_order': return ReferenceType.purchaseOrder;
      case 'sales_order': return ReferenceType.salesOrder;
      case 'invoice': return ReferenceType.invoice;
      case 'return_order': return ReferenceType.returnOrder;
      case 'manual': return ReferenceType.manual;
      case 'transfer': return ReferenceType.transfer;
      default: return null;
    }
  }
}

extension AdjustmentReasonX on AdjustmentReason {
  String get dbValue => name;
  String get label {
    switch (this) {
      case AdjustmentReason.theft: return 'Theft';
      case AdjustmentReason.miscount: return 'Miscount';
      case AdjustmentReason.damage: return 'Damage';
      case AdjustmentReason.expiry: return 'Expiry';
      case AdjustmentReason.correction: return 'Correction';
      case AdjustmentReason.other: return 'Other';
    }
  }

  static AdjustmentReason? fromDb(String? value) {
    if (value == null) return null;
    return AdjustmentReason.values.firstWhere(
      (r) => r.dbValue == value,
      orElse: () => AdjustmentReason.other,
    );
  }
}
