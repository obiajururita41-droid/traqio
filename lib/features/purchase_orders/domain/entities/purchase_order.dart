import 'package:equatable/equatable.dart';
import 'package:traqio/features/purchase_orders/domain/entities/po_enums.dart';
import 'package:traqio/features/purchase_orders/domain/entities/purchase_order_item.dart';

class PurchaseOrder extends Equatable {
  final String id;
  final String businessId;
  final String supplierId;
  final String? supplierName;
  final String poNumber;
  final PurchaseOrderStatus status;
  final DateTime orderDate;
  final DateTime? expectedDeliveryDate;
  final String? notes;
  final double subtotal;
  final double taxAmount;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final List<PurchaseOrderItem> items;

  const PurchaseOrder({
    required this.id,
    required this.businessId,
    required this.supplierId,
    this.supplierName,
    required this.poNumber,
    this.status = PurchaseOrderStatus.draft,
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

  bool get canEdit => status == PurchaseOrderStatus.draft;
  bool get canCancel => status == PurchaseOrderStatus.draft || status == PurchaseOrderStatus.sent;
  bool get canReceive =>
      status == PurchaseOrderStatus.sent || status == PurchaseOrderStatus.partiallyReceived;
  bool get isOverdue =>
      expectedDeliveryDate != null &&
      expectedDeliveryDate!.isBefore(DateTime.now()) &&
      status != PurchaseOrderStatus.received &&
      status != PurchaseOrderStatus.cancelled;

  @override
  List<Object?> get props => [
        id, businessId, supplierId, supplierName, poNumber, status, orderDate,
        expectedDeliveryDate, notes, subtotal, taxAmount, totalAmount,
        createdAt, updatedAt, createdBy, items,
      ];
}
