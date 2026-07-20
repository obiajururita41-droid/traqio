import 'package:traqio/features/sales_orders/domain/entities/sales_order_item.dart';

class SalesOrderItemModel extends SalesOrderItem {
  const SalesOrderItemModel({
    required super.id,
    required super.salesOrderId,
    required super.productId,
    super.productName,
    required super.quantityOrdered,
    super.quantityFulfilled,
    required super.unitPrice,
    super.taxRate,
    super.lineTotal,
  });

  factory SalesOrderItemModel.fromJson(Map<String, dynamic> json) {
    String? productName;
    final productJoin = json['products'];
    if (productJoin is Map<String, dynamic>) {
      productName = productJoin['name'] as String?;
    }
    return SalesOrderItemModel(
      id: json['id'] as String,
      salesOrderId: json['sales_order_id'] as String,
      productId: json['product_id'] as String,
      productName: productName,
      quantityOrdered: (json['quantity_ordered'] as num).toDouble(),
      quantityFulfilled: (json['quantity_fulfilled'] as num?)?.toDouble() ?? 0,
      unitPrice: (json['unit_price'] as num).toDouble(),
      taxRate: (json['tax_rate'] as num?)?.toDouble() ?? 0,
      lineTotal: (json['line_total'] as num?)?.toDouble() ?? 0,
    );
  }
}
