import 'package:traqio/core/enums/payment_method.dart';
import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/payments/domain/entities/payment.dart';
import 'package:traqio/features/payments/domain/entities/payment_enums.dart';
import 'package:traqio/features/payments/domain/entities/payment_metrics.dart';
import 'package:traqio/features/payments/domain/repositories/payment_repository.dart';

class GetPaymentsUseCase {
  final PaymentRepository repository;
  const GetPaymentsUseCase(this.repository);
  Future<Result<List<Payment>>> call({
    PaymentType? typeFilter,
    String? searchQuery,
    required int offset,
    required int limit,
    required bool newestFirst,
  }) {
    return repository.getPayments(
      typeFilter: typeFilter,
      searchQuery: searchQuery,
      offset: offset,
      limit: limit,
      newestFirst: newestFirst,
    );
  }
}

class GetPaymentByIdUseCase {
  final PaymentRepository repository;
  const GetPaymentByIdUseCase(this.repository);
  Future<Result<Payment>> call(String id) => repository.getPaymentById(id);
}

class RecordCustomerPaymentUseCase {
  final PaymentRepository repository;
  const RecordCustomerPaymentUseCase(this.repository);
  Future<Result<Payment>> call({
    required String customerId,
    required double amount,
    PaymentMethod? paymentMethod,
    String? paymentReference,
    required DateTime paymentDate,
    String? notes,
  }) {
    return repository.recordCustomerPayment(
      customerId: customerId,
      amount: amount,
      paymentMethod: paymentMethod,
      paymentReference: paymentReference,
      paymentDate: paymentDate,
      notes: notes,
    );
  }
}

class RecordSupplierPaymentUseCase {
  final PaymentRepository repository;
  const RecordSupplierPaymentUseCase(this.repository);
  Future<Result<Payment>> call({
    required String supplierId,
    required double amount,
    PaymentMethod? paymentMethod,
    String? paymentReference,
    required DateTime paymentDate,
    String? notes,
  }) {
    return repository.recordSupplierPayment(
      supplierId: supplierId,
      amount: amount,
      paymentMethod: paymentMethod,
      paymentReference: paymentReference,
      paymentDate: paymentDate,
      notes: notes,
    );
  }
}

class GetPaymentMetricsUseCase {
  final PaymentRepository repository;
  const GetPaymentMetricsUseCase(this.repository);
  Future<Result<PaymentMetrics>> call() => repository.getMetrics();
}
