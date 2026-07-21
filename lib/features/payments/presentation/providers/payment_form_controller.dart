import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/enums/payment_method.dart';
import 'package:traqio/core/errors/failures.dart';
import 'package:traqio/features/customers/presentation/providers/customer_providers.dart';
import 'package:traqio/features/payments/domain/entities/payment.dart';
import 'package:traqio/features/payments/presentation/providers/payment_providers.dart';
import 'package:traqio/features/suppliers/presentation/providers/supplier_providers.dart';

sealed class PaymentFormState {
  const PaymentFormState();
}

class PaymentFormInitial extends PaymentFormState {
  const PaymentFormInitial();
}

class PaymentFormLoading extends PaymentFormState {
  const PaymentFormLoading();
}

class PaymentFormSuccess extends PaymentFormState {
  final Payment payment;
  const PaymentFormSuccess(this.payment);
}

class PaymentFormError extends PaymentFormState {
  final Failure failure;
  const PaymentFormError(this.failure);
}

/// Drives standalone (on-account) payment recording — not tied to a
/// specific invoice. Invoice-linked payments still go through
/// InvoicePaymentController (Step 12), which posts to the same
/// underlying payments table via the extended record_invoice_payment
/// RPC — this controller is deliberately not a replacement for that.
class PaymentFormController extends StateNotifier<PaymentFormState> {
  final Ref ref;
  PaymentFormController(this.ref) : super(const PaymentFormInitial());

  Future<void> recordCustomerPayment({
    required String customerId,
    required double amount,
    PaymentMethod? paymentMethod,
    String? paymentReference,
    required DateTime paymentDate,
    String? notes,
  }) async {
    state = const PaymentFormLoading();
    final useCase = ref.read(recordCustomerPaymentUseCaseProvider);
    final result = await useCase(
      customerId: customerId,
      amount: amount,
      paymentMethod: paymentMethod,
      paymentReference: paymentReference,
      paymentDate: paymentDate,
      notes: notes,
    );

    result.match(
      (failure) => state = PaymentFormError(failure),
      (payment) {
        state = PaymentFormSuccess(payment);
        ref.read(paymentListProvider.notifier).refresh();
        ref.invalidate(paymentMetricsProvider);
        ref.invalidate(customerLedgerProvider(customerId));
        ref.invalidate(customersProvider);
      },
    );
  }

  Future<void> recordSupplierPayment({
    required String supplierId,
    required double amount,
    PaymentMethod? paymentMethod,
    String? paymentReference,
    required DateTime paymentDate,
    String? notes,
  }) async {
    state = const PaymentFormLoading();
    final useCase = ref.read(recordSupplierPaymentUseCaseProvider);
    final result = await useCase(
      supplierId: supplierId,
      amount: amount,
      paymentMethod: paymentMethod,
      paymentReference: paymentReference,
      paymentDate: paymentDate,
      notes: notes,
    );

    result.match(
      (failure) => state = PaymentFormError(failure),
      (payment) {
        state = PaymentFormSuccess(payment);
        ref.read(paymentListProvider.notifier).refresh();
        ref.invalidate(paymentMetricsProvider);
        ref.invalidate(supplierLedgerProvider(supplierId));
        ref.invalidate(suppliersProvider);
      },
    );
  }

  void reset() => state = const PaymentFormInitial();
}

final paymentFormControllerProvider =
    StateNotifierProvider<PaymentFormController, PaymentFormState>((ref) {
  return PaymentFormController(ref);
});
