import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/errors/failures.dart';
import 'package:traqio/features/customers/presentation/providers/customer_providers.dart';
import 'package:traqio/features/sales_orders/domain/entities/sales_order.dart';
import 'package:traqio/features/sales_orders/domain/entities/sales_order_inputs.dart';
import 'package:traqio/features/sales_orders/presentation/providers/sales_order_providers.dart';
import 'package:traqio/features/stock_movements/presentation/providers/inventory_providers.dart';

sealed class FulfillOrderState {
  const FulfillOrderState();
}

class FulfillOrderInitial extends FulfillOrderState {
  const FulfillOrderInitial();
}

class FulfillOrderLoading extends FulfillOrderState {
  const FulfillOrderLoading();
}

class FulfillOrderSuccess extends FulfillOrderState {
  final SalesOrder salesOrder;
  const FulfillOrderSuccess(this.salesOrder);
}

class FulfillOrderError extends FulfillOrderState {
  final Failure failure;
  const FulfillOrderError(this.failure);
}

/// Drives the "Fulfill Sales Order" action. On success, invalidates
/// Inventory's stock valuation/movement history (fulfilling posts
/// stock-out movements) and the customer's ledger (it also posts a
/// debit) — keeping every dependent screen in sync automatically.
/// On failure (e.g. insufficient stock, raised by the RPC itself),
/// the error surfaces directly from the database's own validation.
class FulfillOrderController extends StateNotifier<FulfillOrderState> {
  final Ref ref;
  FulfillOrderController(this.ref) : super(const FulfillOrderInitial());

  Future<void> fulfill({
    required String soId,
    required String customerId,
    required List<FulfillmentInput> fulfillments,
  }) async {
    state = const FulfillOrderLoading();
    final useCase = ref.read(fulfillSalesOrderItemsUseCaseProvider);
    final result = await useCase(soId: soId, fulfillments: fulfillments);

    result.match(
      (failure) => state = FulfillOrderError(failure),
      (so) {
        state = FulfillOrderSuccess(so);
        ref.invalidate(salesOrderDetailProvider(soId));
        ref.read(salesOrderListProvider.notifier).refresh();
        ref.invalidate(salesOrderMetricsProvider);
        ref.invalidate(movementHistoryProvider);
        ref.invalidate(stockValuationProvider);
        ref.invalidate(customerLedgerProvider(customerId));
        ref.invalidate(customersProvider);
      },
    );
  }

  void reset() => state = const FulfillOrderInitial();
}

final fulfillOrderControllerProvider =
    StateNotifierProvider<FulfillOrderController, FulfillOrderState>((ref) {
  return FulfillOrderController(ref);
});
