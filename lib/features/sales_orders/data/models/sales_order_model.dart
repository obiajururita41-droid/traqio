import 'package:traqio/features/sales_orders/data/models/sales_order_item_model.dart';
import 'package:traqio/features/sales_orders/domain/entities/sales_order.dart';
import 'package:traqio/features/sales_orders/domain/entities/so_enums.dart';

class SalesOrderModel extends SalesOrder {
  const SalesOrderModel({
    required super.id,
    required super.businessId,
    required super.customerId,
    super.customerName,
    required super.soNumber,
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

  factory SalesOrderModel.fromJson(Map<String, dynamic> json) {
    String? customerName;
    final customerJoin = json['customers'];
    if (customerJoin is Map<String, dynamic>) {
      customerName = customerJoin['name'] as String?;
    }

    final itemsJson = json['sales_order_items'] as List?;
    final items = itemsJson
            ?.map((row) => SalesOrderItemModel.fromJson(row as Map<String, dynamic>))
            .toList() ??
        const <SalesOrderItemModel>[];

    return SalesOrderModel(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      customerId: json['customer_id'] as String,
      customerName: customerName,
      soNumber: json['so_number'] as String,
      status: SalesOrderStatusX.fromDb(json['status'] as String? ?? 'draft'),
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
