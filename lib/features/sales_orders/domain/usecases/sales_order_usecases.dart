import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/sales_orders/domain/entities/sales_order.dart';
import 'package:traqio/features/sales_orders/domain/entities/sales_order_inputs.dart';
import 'package:traqio/features/sales_orders/domain/entities/so_enums.dart';
import 'package:traqio/features/sales_orders/domain/repositories/sales_order_repository.dart';

class GetSalesOrdersUseCase {
  final SalesOrderRepository repository;
  const GetSalesOrdersUseCase(this.repository);
  Future<Result<List<SalesOrder>>> call({
    SalesOrderStatus? statusFilter,
    String? searchQuery,
    required int offset,
    required int limit,
    required bool newestFirst,
  }) {
    return repository.getSalesOrders(
      statusFilter: statusFilter,
      searchQuery: searchQuery,
      offset: offset,
      limit: limit,
      newestFirst: newestFirst,
    );
  }
}

class GetSalesOrderByIdUseCase {
  final SalesOrderRepository repository;
  const GetSalesOrderByIdUseCase(this.repository);
  Future<Result<SalesOrder>> call(String id) => repository.getSalesOrderById(id);
}

class CreateSalesOrderUseCase {
  final SalesOrderRepository repository;
  const CreateSalesOrderUseCase(this.repository);
  Future<Result<SalesOrder>> call({
    required String customerId,
    required String soNumber,
    required DateTime orderDate,
    DateTime? expectedDeliveryDate,
    String? notes,
    required List<SalesOrderItemInput> items,
  }) {
    return repository.createSalesOrder(
      customerId: customerId,
      soNumber: soNumber,
      orderDate: orderDate,
      expectedDeliveryDate: expectedDeliveryDate,
      notes: notes,
      items: items,
    );
  }
}

class UpdateSalesOrderUseCase {
  final SalesOrderRepository repository;
  const UpdateSalesOrderUseCase(this.repository);
  Future<Result<SalesOrder>> call({
    required String id,
    required String customerId,
    required DateTime orderDate,
    DateTime? expectedDeliveryDate,
    String? notes,
    required List<SalesOrderItemInput> items,
  }) {
    return repository.updateSalesOrder(
      id: id,
      customerId: customerId,
      orderDate: orderDate,
      expectedDeliveryDate: expectedDeliveryDate,
      notes: notes,
      items: items,
    );
  }
}

class ConfirmSalesOrderUseCase {
  final SalesOrderRepository repository;
  const ConfirmSalesOrderUseCase(this.repository);
  Future<Result<SalesOrder>> call(String id) => repository.confirmSalesOrder(id);
}

class CancelSalesOrderUseCase {
  final SalesOrderRepository repository;
  const CancelSalesOrderUseCase(this.repository);
  Future<Result<SalesOrder>> call(String id) => repository.cancelSalesOrder(id);
}

class FulfillSalesOrderItemsUseCase {
  final SalesOrderRepository repository;
  const FulfillSalesOrderItemsUseCase(this.repository);
  Future<Result<SalesOrder>> call({
    required String soId,
    required List<FulfillmentInput> fulfillments,
  }) {
    return repository.fulfillItems(soId: soId, fulfillments: fulfillments);
  }
}

class GetSalesOrderMetricsUseCase {
  final SalesOrderRepository repository;
  const GetSalesOrderMetricsUseCase(this.repository);
  Future<Result<SalesOrderMetrics>> call() => repository.getMetrics();
}
