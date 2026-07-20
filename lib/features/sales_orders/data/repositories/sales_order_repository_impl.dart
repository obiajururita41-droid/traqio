import 'package:traqio/core/errors/failures.dart';
import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/sales_orders/data/datasources/sales_order_remote_datasource.dart';
import 'package:traqio/features/sales_orders/domain/entities/sales_order.dart';
import 'package:traqio/features/sales_orders/domain/entities/sales_order_inputs.dart';
import 'package:traqio/features/sales_orders/domain/entities/so_enums.dart';
import 'package:traqio/features/sales_orders/domain/repositories/sales_order_repository.dart';

class SalesOrderRepositoryImpl implements SalesOrderRepository {
  final SalesOrderRemoteDataSource remoteDataSource;
  const SalesOrderRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<SalesOrder>>> getSalesOrders({
    SalesOrderStatus? statusFilter,
    String? searchQuery,
    required int offset,
    required int limit,
    required bool newestFirst,
  }) async {
    try {
      final orders = await remoteDataSource.getSalesOrders(
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
  Future<Result<SalesOrder>> getSalesOrderById(String id) async {
    try {
      return Result.right(await remoteDataSource.getSalesOrderById(id));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<SalesOrder>> createSalesOrder({
    required String customerId,
    required String soNumber,
    required DateTime orderDate,
    DateTime? expectedDeliveryDate,
    String? notes,
    required List<SalesOrderItemInput> items,
  }) async {
    try {
      final so = await remoteDataSource.createSalesOrder(
        customerId: customerId,
        soNumber: soNumber,
        orderDate: orderDate,
        expectedDeliveryDate: expectedDeliveryDate,
        notes: notes,
        items: items,
      );
      return Result.right(so);
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<SalesOrder>> updateSalesOrder({
    required String id,
    required String customerId,
    required DateTime orderDate,
    DateTime? expectedDeliveryDate,
    String? notes,
    required List<SalesOrderItemInput> items,
  }) async {
    try {
      final so = await remoteDataSource.updateSalesOrder(
        id: id,
        customerId: customerId,
        orderDate: orderDate,
        expectedDeliveryDate: expectedDeliveryDate,
        notes: notes,
        items: items,
      );
      return Result.right(so);
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<SalesOrder>> confirmSalesOrder(String id) async {
    try {
      return Result.right(await remoteDataSource.confirmSalesOrder(id));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<SalesOrder>> cancelSalesOrder(String id) async {
    try {
      return Result.right(await remoteDataSource.cancelSalesOrder(id));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<SalesOrder>> fulfillItems({
    required String soId,
    required List<FulfillmentInput> fulfillments,
  }) async {
    try {
      final so = await remoteDataSource.fulfillItems(soId: soId, fulfillments: fulfillments);
      return Result.right(so);
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<SalesOrderMetrics>> getMetrics() async {
    try {
      final raw = await remoteDataSource.getMetricsRaw();
      return Result.right(SalesOrderMetrics(
        openOrdersCount: raw['open_orders_count'] as int,
        overdueCount: raw['overdue_count'] as int,
        pendingValue: (raw['pending_value'] as num).toDouble(),
      ));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }
}
