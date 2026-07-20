import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/errors/failures.dart';
import 'package:traqio/features/customers/presentation/providers/customer_providers.dart';
import 'package:traqio/features/invoices/domain/entities/invoice.dart';
import 'package:traqio/features/invoices/domain/entities/invoice_enums.dart';
import 'package:traqio/features/invoices/presentation/providers/invoice_providers.dart';

sealed class InvoicePaymentState {
  const InvoicePaymentState();
}

class InvoicePaymentInitial extends InvoicePaymentState {
  const InvoicePaymentInitial();
}

class InvoicePaymentLoading extends InvoicePaymentState {
  const InvoicePaymentLoading();
}

class InvoicePaymentSuccess extends InvoicePaymentState {
  final Invoice invoice;
  const InvoicePaymentSuccess(this.invoice);
}

class InvoicePaymentError extends InvoicePaymentState {
  final Failure failure;
  const InvoicePaymentError(this.failure);
}

/// Drives payment recording. On success, invalidates the invoice
/// detail/payments history AND the customer's ledger (since the RPC
/// posts a credit there), keeping every dependent screen in sync.
class InvoicePaymentController extends StateNotifier<InvoicePaymentState> {
  final Ref ref;
  InvoicePaymentController(this.ref) : super(const InvoicePaymentInitial());

  Future<void> recordPayment({
    required String invoiceId,
    required String customerId,
    required double amount,
    PaymentMethod? paymentMethod,
    required DateTime paymentDate,
    String? notes,
  }) async {
    state = const InvoicePaymentLoading();
    final useCase = ref.read(recordInvoicePaymentUseCaseProvider);
    final result = await useCase(
      invoiceId: invoiceId,
      amount: amount,
      paymentMethod: paymentMethod,
      paymentDate: paymentDate,
      notes: notes,
    );

    result.match(
      (failure) => state = InvoicePaymentError(failure),
      (invoice) {
        state = InvoicePaymentSuccess(invoice);
        ref.invalidate(invoiceDetailProvider(invoiceId));
        ref.invalidate(invoicePaymentsProvider(invoiceId));
        ref.read(invoiceListProvider.notifier).refresh();
        ref.invalidate(invoiceMetricsProvider);
        ref.invalidate(customerLedgerProvider(customerId));
        ref.invalidate(customersProvider);
      },
    );
  }

  void reset() => state = const InvoicePaymentInitial();
}

final invoicePaymentControllerProvider =
    StateNotifierProvider<InvoicePaymentController, InvoicePaymentState>((ref) {
  return InvoicePaymentController(ref);
});
