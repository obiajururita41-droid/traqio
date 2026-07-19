import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/errors/failures.dart';
import 'package:traqio/features/purchase_orders/domain/entities/purchase_order.dart';
import 'package:traqio/features/purchase_orders/domain/entities/purchase_order_inputs.dart';
import 'package:traqio/features/purchase_orders/presentation/providers/purchase_order_providers.dart';
import 'package:traqio/features/stock_movements/presentation/providers/inventory_providers.dart';
import 'package:traqio/features/suppliers/presentation/providers/supplier_providers.dart';

sealed class ReceiveOrderState {
  const ReceiveOrderState();
}

class ReceiveOrderInitial extends ReceiveOrderState {
  const ReceiveOrderInitial();
}

class ReceiveOrderLoading extends ReceiveOrderState {
  const ReceiveOrderLoading();
}

class ReceiveOrderSuccess extends ReceiveOrderState {
  final PurchaseOrder purchaseOrder;
  const ReceiveOrderSuccess(this.purchaseOrder);
}

class ReceiveOrderError extends ReceiveOrderState {
  final Failure failure;
  const ReceiveOrderError(this.failure);
}

/// Drives the "Receive Purchase Order" action. On success, invalidates
/// Inventory's stock valuation and movement history (since receiving
/// posts stock-in movements) and the supplier's ledger (since it also
/// posts a supplier ledger credit) — keeping every dependent screen
/// automatically in sync without manual refresh logic scattered around.
class ReceiveOrderController extends StateNotifier<ReceiveOrderState> {
  final Ref ref;
  ReceiveOrderController(this.ref) : super(const ReceiveOrderInitial());

  Future<void> receive({
    required String poId,
    required String supplierId,
    required List<ReceiptInput> receipts,
  }) async {
    state = const ReceiveOrderLoading();
    final useCase = ref.read(receivePurchaseOrderItemsUseCaseProvider);
    final result = await useCase(poId: poId, receipts: receipts);

    result.match(
      (failure) => state = ReceiveOrderError(failure),
      (po) {
        state = ReceiveOrderSuccess(po);
        ref.invalidate(purchaseOrderDetailProvider(poId));
        ref.read(purchaseOrderListProvider.notifier).refresh();
        ref.invalidate(purchaseOrderMetricsProvider);
        ref.invalidate(movementHistoryProvider);
        ref.invalidate(stockValuationProvider);
        ref.invalidate(supplierLedgerProvider(supplierId));
        ref.invalidate(suppliersProvider);
      },
    );
  }

  void reset() => state = const ReceiveOrderInitial();
}

final receiveOrderControllerProvider =
    StateNotifierProvider<ReceiveOrderController, ReceiveOrderState>((ref) {
  return ReceiveOrderController(ref);
});
