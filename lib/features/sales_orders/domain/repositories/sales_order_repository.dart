import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/sales_orders/domain/entities/sales_order.dart';
import 'package:traqio/features/sales_orders/domain/entities/sales_order_inputs.dart';
import 'package:traqio/features/sales_orders/domain/entities/so_enums.dart';

abstract class SalesOrderRepository {
  Future<Result<List<SalesOrder>>> getSalesOrders({
    SalesOrderStatus? statusFilter,
    String? searchQuery,
    required int offset,
    required int limit,
    required bool newestFirst,
  });

  Future<Result<SalesOrder>> getSalesOrderById(String id);

  Future<Result<SalesOrder>> createSalesOrder({
    required String customerId,
    required String soNumber,
    required DateTime orderDate,
    DateTime? expectedDeliveryDate,
    String? notes,
    required List<SalesOrderItemInput> items,
  });

  Future<Result<SalesOrder>> updateSalesOrder({
    required String id,
    required String customerId,
    required DateTime orderDate,
    DateTime? expectedDeliveryDate,
    String? notes,
    required List<SalesOrderItemInput> items,
  });

  Future<Result<SalesOrder>> confirmSalesOrder(String id);
  Future<Result<SalesOrder>> cancelSalesOrder(String id);
  Future<Result<SalesOrder>> fulfillItems({
    required String soId,
    required List<FulfillmentInput> fulfillments,
  });

  Future<Result<SalesOrderMetrics>> getMetrics();
}
