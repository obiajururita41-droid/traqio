import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/purchase_orders/domain/entities/po_enums.dart';
import 'package:traqio/features/purchase_orders/domain/entities/purchase_order.dart';
import 'package:traqio/features/purchase_orders/domain/entities/purchase_order_inputs.dart';

abstract class PurchaseOrderRepository {
  Future<Result<List<PurchaseOrder>>> getPurchaseOrders({
    PurchaseOrderStatus? statusFilter,
    String? searchQuery,
    required int offset,
    required int limit,
    required bool newestFirst,
  });

  Future<Result<PurchaseOrder>> getPurchaseOrderById(String id);

  Future<Result<PurchaseOrder>> createPurchaseOrder({
    required String supplierId,
    required String poNumber,
    required DateTime orderDate,
    DateTime? expectedDeliveryDate,
    String? notes,
    required List<PurchaseOrderItemInput> items,
  });

  Future<Result<PurchaseOrder>> updatePurchaseOrder({
    required String id,
    required String supplierId,
    required DateTime orderDate,
    DateTime? expectedDeliveryDate,
    String? notes,
    required List<PurchaseOrderItemInput> items,
  });

  Future<Result<PurchaseOrder>> markAsSent(String id);
  Future<Result<PurchaseOrder>> cancelPurchaseOrder(String id);
  Future<Result<PurchaseOrder>> receiveItems({
    required String poId,
    required List<ReceiptInput> receipts,
  });

  Future<Result<PurchaseOrderMetrics>> getMetrics();
}
