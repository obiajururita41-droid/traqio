import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/purchase_orders/domain/entities/po_enums.dart';
import 'package:traqio/features/purchase_orders/domain/entities/purchase_order.dart';
import 'package:traqio/features/purchase_orders/domain/entities/purchase_order_inputs.dart';
import 'package:traqio/features/purchase_orders/domain/repositories/purchase_order_repository.dart';

class GetPurchaseOrdersUseCase {
  final PurchaseOrderRepository repository;
  const GetPurchaseOrdersUseCase(this.repository);
  Future<Result<List<PurchaseOrder>>> call({
    PurchaseOrderStatus? statusFilter,
    String? searchQuery,
    required int offset,
    required int limit,
    required bool newestFirst,
  }) {
    return repository.getPurchaseOrders(
      statusFilter: statusFilter,
      searchQuery: searchQuery,
      offset: offset,
      limit: limit,
      newestFirst: newestFirst,
    );
  }
}

class GetPurchaseOrderByIdUseCase {
  final PurchaseOrderRepository repository;
  const GetPurchaseOrderByIdUseCase(this.repository);
  Future<Result<PurchaseOrder>> call(String id) => repository.getPurchaseOrderById(id);
}

class CreatePurchaseOrderUseCase {
  final PurchaseOrderRepository repository;
  const CreatePurchaseOrderUseCase(this.repository);
  Future<Result<PurchaseOrder>> call({
    required String supplierId,
    required String poNumber,
    required DateTime orderDate,
    DateTime? expectedDeliveryDate,
    String? notes,
    required List<PurchaseOrderItemInput> items,
  }) {
    return repository.createPurchaseOrder(
      supplierId: supplierId,
      poNumber: poNumber,
      orderDate: orderDate,
      expectedDeliveryDate: expectedDeliveryDate,
      notes: notes,
      items: items,
    );
  }
}

class UpdatePurchaseOrderUseCase {
  final PurchaseOrderRepository repository;
  const UpdatePurchaseOrderUseCase(this.repository);
  Future<Result<PurchaseOrder>> call({
    required String id,
    required String supplierId,
    required DateTime orderDate,
    DateTime? expectedDeliveryDate,
    String? notes,
    required List<PurchaseOrderItemInput> items,
  }) {
    return repository.updatePurchaseOrder(
      id: id,
      supplierId: supplierId,
      orderDate: orderDate,
      expectedDeliveryDate: expectedDeliveryDate,
      notes: notes,
      items: items,
    );
  }
}

class MarkPurchaseOrderAsSentUseCase {
  final PurchaseOrderRepository repository;
  const MarkPurchaseOrderAsSentUseCase(this.repository);
  Future<Result<PurchaseOrder>> call(String id) => repository.markAsSent(id);
}

class CancelPurchaseOrderUseCase {
  final PurchaseOrderRepository repository;
  const CancelPurchaseOrderUseCase(this.repository);
  Future<Result<PurchaseOrder>> call(String id) => repository.cancelPurchaseOrder(id);
}

class ReceivePurchaseOrderItemsUseCase {
  final PurchaseOrderRepository repository;
  const ReceivePurchaseOrderItemsUseCase(this.repository);
  Future<Result<PurchaseOrder>> call({
    required String poId,
    required List<ReceiptInput> receipts,
  }) {
    return repository.receiveItems(poId: poId, receipts: receipts);
  }
}

class GetPurchaseOrderMetricsUseCase {
  final PurchaseOrderRepository repository;
  const GetPurchaseOrderMetricsUseCase(this.repository);
  Future<Result<PurchaseOrderMetrics>> call() => repository.getMetrics();
}
