import 'package:equatable/equatable.dart';
import 'package:traqio/features/sales_orders/domain/entities/sales_order_item.dart';
import 'package:traqio/features/sales_orders/domain/entities/so_enums.dart';

class SalesOrder extends Equatable {
  final String id;
  final String businessId;
  final String customerId;
  final String? customerName;
  final String soNumber;
  final SalesOrderStatus status;
  final DateTime orderDate;
  final DateTime? expectedDeliveryDate;
  final String? notes;
  final double subtotal;
  final double taxAmount;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final List<SalesOrderItem> items;

  const SalesOrder({
    required this.id,
    required this.businessId,
    required this.customerId,
    this.customerName,
    required this.soNumber,
    this.status = SalesOrderStatus.draft,
    required this.orderDate,
    this.expectedDeliveryDate,
    this.notes,
    this.subtotal = 0,
    this.taxAmount = 0,
    this.totalAmount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.items = const [],
  });

  bool get canEdit => status == SalesOrderStatus.draft;
  bool get canCancel => status == SalesOrderStatus.draft || status == SalesOrderStatus.confirmed;
  bool get canFulfill =>
      status == SalesOrderStatus.confirmed || status == SalesOrderStatus.partiallyFulfilled;
  bool get isOverdue =>
      expectedDeliveryDate != null &&
      expectedDeliveryDate!.isBefore(DateTime.now()) &&
      status != SalesOrderStatus.fulfilled &&
      status != SalesOrderStatus.cancelled;

  @override
  List<Object?> get props => [
        id, businessId, customerId, customerName, soNumber, status, orderDate,
        expectedDeliveryDate, notes, subtotal, taxAmount, totalAmount,
        createdAt, updatedAt, createdBy, items,
      ];
}
