import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/errors/failures.dart';
import 'package:traqio/features/sales_orders/domain/entities/sales_order.dart';
import 'package:traqio/features/sales_orders/domain/entities/sales_order_inputs.dart';
import 'package:traqio/features/sales_orders/presentation/providers/sales_order_providers.dart';

sealed class SalesOrderFormState {
  const SalesOrderFormState();
}

class SalesOrderFormInitial extends SalesOrderFormState {
  const SalesOrderFormInitial();
}

class SalesOrderFormLoading extends SalesOrderFormState {
  const SalesOrderFormLoading();
}

class SalesOrderFormSuccess extends SalesOrderFormState {
  final SalesOrder salesOrder;
  const SalesOrderFormSuccess(this.salesOrder);
}

class SalesOrderFormError extends SalesOrderFormState {
  final Failure failure;
  const SalesOrderFormError(this.failure);
}

class SalesOrderFormController extends StateNotifier<SalesOrderFormState> {
  final Ref ref;
  SalesOrderFormController(this.ref) : super(const SalesOrderFormInitial());

  Future<void> create({
    required String customerId,
    required String soNumber,
    required DateTime orderDate,
    DateTime? expectedDeliveryDate,
    String? notes,
    required List<SalesOrderItemInput> items,
  }) async {
    state = const SalesOrderFormLoading();
    final useCase = ref.read(createSalesOrderUseCaseProvider);
    final result = await useCase(
      customerId: customerId,
      soNumber: soNumber,
      orderDate: orderDate,
      expectedDeliveryDate: expectedDeliveryDate,
      notes: notes,
      items: items,
    );
    result.match(
      (failure) => state = SalesOrderFormError(failure),
      (so) {
        state = SalesOrderFormSuccess(so);
        ref.read(salesOrderListProvider.notifier).refresh();
      },
    );
  }

  Future<void> update({
    required String id,
    required String customerId,
    required DateTime orderDate,
    DateTime? expectedDeliveryDate,
    String? notes,
    required List<SalesOrderItemInput> items,
  }) async {
    state = const SalesOrderFormLoading();
    final useCase = ref.read(updateSalesOrderUseCaseProvider);
    final result = await useCase(
      id: id,
      customerId: customerId,
      orderDate: orderDate,
      expectedDeliveryDate: expectedDeliveryDate,
      notes: notes,
      items: items,
    );
    result.match(
      (failure) => state = SalesOrderFormError(failure),
      (so) {
        state = SalesOrderFormSuccess(so);
        ref.invalidate(salesOrderDetailProvider(id));
        ref.read(salesOrderListProvider.notifier).refresh();
      },
    );
  }

  Future<void> confirm(String id) async {
    state = const SalesOrderFormLoading();
    final useCase = ref.read(confirmSalesOrderUseCaseProvider);
    final result = await useCase(id);
    result.match(
      (failure) => state = SalesOrderFormError(failure),
      (so) {
        state = SalesOrderFormSuccess(so);
        ref.invalidate(salesOrderDetailProvider(id));
        ref.read(salesOrderListProvider.notifier).refresh();
      },
    );
  }

  Future<void> cancel(String id) async {
    state = const SalesOrderFormLoading();
    final useCase = ref.read(cancelSalesOrderUseCaseProvider);
    final result = await useCase(id);
    result.match(
      (failure) => state = SalesOrderFormError(failure),
      (so) {
        state = SalesOrderFormSuccess(so);
        ref.invalidate(salesOrderDetailProvider(id));
        ref.read(salesOrderListProvider.notifier).refresh();
      },
    );
  }

  void reset() => state = const SalesOrderFormInitial();
}

final salesOrderFormControllerProvider =
    StateNotifierProvider<SalesOrderFormController, SalesOrderFormState>((ref) {
  return SalesOrderFormController(ref);
});
