import 'package:traqio/core/enums/payment_method.dart';
import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/payments/domain/entities/payment.dart';
import 'package:traqio/features/payments/domain/entities/payment_enums.dart';
import 'package:traqio/features/payments/domain/entities/payment_metrics.dart';

abstract class PaymentRepository {
  Future<Result<List<Payment>>> getPayments({
    PaymentType? typeFilter,
    String? searchQuery,
    required int offset,
    required int limit,
    required bool newestFirst,
  });

  Future<Result<Payment>> getPaymentById(String id);

  Future<Result<Payment>> recordCustomerPayment({
    required String customerId,
    required double amount,
    PaymentMethod? paymentMethod,
    String? paymentReference,
    required DateTime paymentDate,
    String? notes,
  });

  Future<Result<Payment>> recordSupplierPayment({
    required String supplierId,
    required double amount,
    PaymentMethod? paymentMethod,
    String? paymentReference,
    required DateTime paymentDate,
    String? notes,
  });

  Future<Result<PaymentMetrics>> getMetrics();
}
