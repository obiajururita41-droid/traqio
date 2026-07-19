import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/errors/failures.dart';
import 'package:traqio/features/purchase_orders/domain/entities/purchase_order.dart';
import 'package:traqio/features/purchase_orders/domain/entities/purchase_order_inputs.dart';
import 'package:traqio/features/purchase_orders/presentation/providers/purchase_order_providers.dart';

sealed class PurchaseOrderFormState {
  const PurchaseOrderFormState();
}

class PurchaseOrderFormInitial extends PurchaseOrderFormState {
  const PurchaseOrderFormInitial();
}

class PurchaseOrderFormLoading extends PurchaseOrderFormState {
  const PurchaseOrderFormLoading();
}

class PurchaseOrderFormSuccess extends PurchaseOrderFormState {
  final PurchaseOrder purchaseOrder;
  const PurchaseOrderFormSuccess(this.purchaseOrder);
}

class PurchaseOrderFormError extends PurchaseOrderFormState {
  final Failure failure;
  const PurchaseOrderFormError(this.failure);
}

class PurchaseOrderFormController extends StateNotifier<PurchaseOrderFormState> {
  final Ref ref;
  PurchaseOrderFormController(this.ref) : super(const PurchaseOrderFormInitial());

  Future<void> create({
    required String supplierId,
    required String poNumber,
    required DateTime orderDate,
    DateTime? expectedDeliveryDate,
    String? notes,
    required List<PurchaseOrderItemInput> items,
  }) async {
    state = const PurchaseOrderFormLoading();
    final useCase = ref.read(createPurchaseOrderUseCaseProvider);
    final result = await useCase(
      supplierId: supplierId,
      poNumber: poNumber,
      orderDate: orderDate,
      expectedDeliveryDate: expectedDeliveryDate,
      notes: notes,
      items: items,
    );
    result.match(
      (failure) => state = PurchaseOrderFormError(failure),
      (po) {
        state = PurchaseOrderFormSuccess(po);
        ref.read(purchaseOrderListProvider.notifier).refresh();
      },
    );
  }

  Future<void> update({
    required String id,
    required String supplierId,
    required DateTime orderDate,
    DateTime? expectedDeliveryDate,
    String? notes,
    required List<PurchaseOrderItemInput> items,
  }) async {
    state = const PurchaseOrderFormLoading();
    final useCase = ref.read(updatePurchaseOrderUseCaseProvider);
    final result = await useCase(
      id: id,
      supplierId: supplierId,
      orderDate: orderDate,
      expectedDeliveryDate: expectedDeliveryDate,
      notes: notes,
      items: items,
    );
    result.match(
      (failure) => state = PurchaseOrderFormError(failure),
      (po) {
        state = PurchaseOrderFormSuccess(po);
        ref.invalidate(purchaseOrderDetailProvider(id));
        ref.read(purchaseOrderListProvider.notifier).refresh();
      },
    );
  }

  Future<void> markAsSent(String id) async {
    state = const PurchaseOrderFormLoading();
    final useCase = ref.read(markPurchaseOrderAsSentUseCaseProvider);
    final result = await useCase(id);
    result.match(
      (failure) => state = PurchaseOrderFormError(failure),
      (po) {
        state = PurchaseOrderFormSuccess(po);
        ref.invalidate(purchaseOrderDetailProvider(id));
        ref.read(purchaseOrderListProvider.notifier).refresh();
      },
    );
  }

  Future<void> cancel(String id) async {
    state = const PurchaseOrderFormLoading();
    final useCase = ref.read(cancelPurchaseOrderUseCaseProvider);
    final result = await useCase(id);
    result.match(
      (failure) => state = PurchaseOrderFormError(failure),
      (po) {
        state = PurchaseOrderFormSuccess(po);
        ref.invalidate(purchaseOrderDetailProvider(id));
        ref.read(purchaseOrderListProvider.notifier).refresh();
      },
    );
  }

  void reset() => state = const PurchaseOrderFormInitial();
}

final purchaseOrderFormControllerProvider =
    StateNotifierProvider<PurchaseOrderFormController, PurchaseOrderFormState>((ref) {
  return PurchaseOrderFormController(ref);
});
