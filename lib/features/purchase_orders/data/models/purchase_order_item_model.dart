import 'package:traqio/features/purchase_orders/domain/entities/purchase_order_item.dart';

class PurchaseOrderItemModel extends PurchaseOrderItem {
  const PurchaseOrderItemModel({
    required super.id,
    required super.purchaseOrderId,
    required super.productId,
    super.productName,
    required super.quantityOrdered,
    super.quantityReceived,
    required super.unitCost,
    super.taxRate,
    super.lineTotal,
  });

  factory PurchaseOrderItemModel.fromJson(Map<String, dynamic> json) {
    String? productName;
    final productJoin = json['products'];
    if (productJoin is Map<String, dynamic>) {
      productName = productJoin['name'] as String?;
    }
    return PurchaseOrderItemModel(
      id: json['id'] as String,
      purchaseOrderId: json['purchase_order_id'] as String,
      productId: json['product_id'] as String,
      productName: productName,
      quantityOrdered: (json['quantity_ordered'] as num).toDouble(),
      quantityReceived: (json['quantity_received'] as num?)?.toDouble() ?? 0,
      unitCost: (json['unit_cost'] as num).toDouble(),
      taxRate: (json['tax_rate'] as num?)?.toDouble() ?? 0,
      lineTotal: (json['line_total'] as num?)?.toDouble() ?? 0,
    );
  }
}
