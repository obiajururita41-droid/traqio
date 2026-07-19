import 'package:traqio/features/purchase_orders/data/models/purchase_order_item_model.dart';
import 'package:traqio/features/purchase_orders/domain/entities/po_enums.dart';
import 'package:traqio/features/purchase_orders/domain/entities/purchase_order.dart';

class PurchaseOrderModel extends PurchaseOrder {
  const PurchaseOrderModel({
    required super.id,
    required super.businessId,
    required super.supplierId,
    super.supplierName,
    required super.poNumber,
    super.status,
    required super.orderDate,
    super.expectedDeliveryDate,
    super.notes,
    super.subtotal,
    super.taxAmount,
    super.totalAmount,
    required super.createdAt,
    required super.updatedAt,
    super.createdBy,
    super.items,
  });

  factory PurchaseOrderModel.fromJson(Map<String, dynamic> json) {
    String? supplierName;
    final supplierJoin = json['suppliers'];
    if (supplierJoin is Map<String, dynamic>) {
      supplierName = supplierJoin['name'] as String?;
    }

    final itemsJson = json['purchase_order_items'] as List?;
    final items = itemsJson
            ?.map((row) => PurchaseOrderItemModel.fromJson(row as Map<String, dynamic>))
            .toList() ??
        const <PurchaseOrderItemModel>[];

    return PurchaseOrderModel(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      supplierId: json['supplier_id'] as String,
      supplierName: supplierName,
      poNumber: json['po_number'] as String,
      status: PurchaseOrderStatusX.fromDb(json['status'] as String? ?? 'draft'),
      orderDate: DateTime.parse(json['order_date'] as String),
      expectedDeliveryDate: json['expected_delivery_date'] == null
          ? null
          : DateTime.parse(json['expected_delivery_date'] as String),
      notes: json['notes'] as String?,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      createdBy: json['created_by'] as String?,
      items: items,
    );
  }
}
