import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/errors/failures.dart';
import 'package:traqio/features/invoices/domain/entities/invoice.dart';
import 'package:traqio/features/invoices/presentation/providers/invoice_providers.dart';

sealed class InvoiceFormState {
  const InvoiceFormState();
}

class InvoiceFormInitial extends InvoiceFormState {
  const InvoiceFormInitial();
}

class InvoiceFormLoading extends InvoiceFormState {
  const InvoiceFormLoading();
}

class InvoiceFormSuccess extends InvoiceFormState {
  final Invoice invoice;
  const InvoiceFormSuccess(this.invoice);
}

class InvoiceFormError extends InvoiceFormState {
  final Failure failure;
  const InvoiceFormError(this.failure);
}

class InvoiceFormController extends StateNotifier<InvoiceFormState> {
  final Ref ref;
  InvoiceFormController(this.ref) : super(const InvoiceFormInitial());

  Future<void> generateFromSalesOrder({
    required String salesOrderId,
    required String invoiceNumber,
    DateTime? dueDate,
    String? notes,
  }) async {
    state = const InvoiceFormLoading();
    final useCase = ref.read(generateInvoiceFromSalesOrderUseCaseProvider);
    final result = await useCase(
      salesOrderId: salesOrderId,
      invoiceNumber: invoiceNumber,
      dueDate: dueDate,
      notes: notes,
    );
    result.match(
      (failure) => state = InvoiceFormError(failure),
      (invoice) {
        state = InvoiceFormSuccess(invoice);
        ref.read(invoiceListProvider.notifier).refresh();
      },
    );
  }

  Future<void> markAsSent(String id) async {
    state = const InvoiceFormLoading();
    final useCase = ref.read(markInvoiceAsSentUseCaseProvider);
    final result = await useCase(id);
    result.match(
      (failure) => state = InvoiceFormError(failure),
      (invoice) {
        state = InvoiceFormSuccess(invoice);
        ref.invalidate(invoiceDetailProvider(id));
        ref.read(invoiceListProvider.notifier).refresh();
      },
    );
  }

  Future<void> cancel(String id) async {
    state = const InvoiceFormLoading();
    final useCase = ref.read(cancelInvoiceUseCaseProvider);
    final result = await useCase(id);
    result.match(
      (failure) => state = InvoiceFormError(failure),
      (invoice) {
        state = InvoiceFormSuccess(invoice);
        ref.invalidate(invoiceDetailProvider(id));
        ref.read(invoiceListProvider.notifier).refresh();
      },
    );
  }

  void reset() => state = const InvoiceFormInitial();
}

final invoiceFormControllerProvider =
    StateNotifierProvider<InvoiceFormController, InvoiceFormState>((ref) {
  return InvoiceFormController(ref);
});
