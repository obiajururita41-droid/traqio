import 'package:traqio/core/errors/failures.dart';
import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/purchase_orders/data/datasources/purchase_order_remote_datasource.dart';
import 'package:traqio/features/purchase_orders/domain/entities/po_enums.dart';
import 'package:traqio/features/purchase_orders/domain/entities/purchase_order.dart';
import 'package:traqio/features/purchase_orders/domain/entities/purchase_order_inputs.dart';
import 'package:traqio/features/purchase_orders/domain/repositories/purchase_order_repository.dart';

class PurchaseOrderRepositoryImpl implements PurchaseOrderRepository {
  final PurchaseOrderRemoteDataSource remoteDataSource;
  const PurchaseOrderRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<PurchaseOrder>>> getPurchaseOrders({
    PurchaseOrderStatus? statusFilter,
    String? searchQuery,
    required int offset,
    required int limit,
    required bool newestFirst,
  }) async {
    try {
      final orders = await remoteDataSource.getPurchaseOrders(
        statusFilter: statusFilter,
        searchQuery: searchQuery,
        offset: offset,
        limit: limit,
        newestFirst: newestFirst,
      );
      return Result.right(orders);
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<PurchaseOrder>> getPurchaseOrderById(String id) async {
    try {
      return Result.right(await remoteDataSource.getPurchaseOrderById(id));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<PurchaseOrder>> createPurchaseOrder({
    required String supplierId,
    required String poNumber,
    required DateTime orderDate,
    DateTime? expectedDeliveryDate,
    String? notes,
    required List<PurchaseOrderItemInput> items,
  }) async {
    try {
      final po = await remoteDataSource.createPurchaseOrder(
        supplierId: supplierId,
        poNumber: poNumber,
        orderDate: orderDate,
        expectedDeliveryDate: expectedDeliveryDate,
        notes: notes,
        items: items,
      );
      return Result.right(po);
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<PurchaseOrder>> updatePurchaseOrder({
    required String id,
    required String supplierId,
    required DateTime orderDate,
    DateTime? expectedDeliveryDate,
    String? notes,
    required List<PurchaseOrderItemInput> items,
  }) async {
    try {
      final po = await remoteDataSource.updatePurchaseOrder(
        id: id,
        supplierId: supplierId,
        orderDate: orderDate,
        expectedDeliveryDate: expectedDeliveryDate,
        notes: notes,
        items: items,
      );
      return Result.right(po);
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<PurchaseOrder>> markAsSent(String id) async {
    try {
      return Result.right(await remoteDataSource.markAsSent(id));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<PurchaseOrder>> cancelPurchaseOrder(String id) async {
    try {
      return Result.right(await remoteDataSource.cancelPurchaseOrder(id));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<PurchaseOrder>> receiveItems({
    required String poId,
    required List<ReceiptInput> receipts,
  }) async {
    try {
      final po = await remoteDataSource.receiveItems(poId: poId, receipts: receipts);
      return Result.right(po);
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<PurchaseOrderMetrics>> getMetrics() async {
    try {
      final raw = await remoteDataSource.getMetricsRaw();
      return Result.right(PurchaseOrderMetrics(
        openOrdersCount: raw['open_orders_count'] as int,
        overdueCount: raw['overdue_count'] as int,
        pendingValue: (raw['pending_value'] as num).toDouble(),
      ));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }
}
