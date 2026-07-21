import 'package:traqio/core/enums/payment_method.dart';
import 'package:traqio/core/errors/failures.dart';
import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/payments/data/datasources/payment_remote_datasource.dart';
import 'package:traqio/features/payments/domain/entities/payment.dart';
import 'package:traqio/features/payments/domain/entities/payment_enums.dart';
import 'package:traqio/features/payments/domain/entities/payment_metrics.dart';
import 'package:traqio/features/payments/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;
  const PaymentRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<Payment>>> getPayments({
    PaymentType? typeFilter,
    String? searchQuery,
    required int offset,
    required int limit,
    required bool newestFirst,
  }) async {
    try {
      final payments = await remoteDataSource.getPayments(
        typeFilter: typeFilter,
        searchQuery: searchQuery,
        offset: offset,
        limit: limit,
        newestFirst: newestFirst,
      );
      return Result.right(payments);
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Payment>> getPaymentById(String id) async {
    try {
      return Result.right(await remoteDataSource.getPaymentById(id));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Payment>> recordCustomerPayment({
    required String customerId,
    required double amount,
    PaymentMethod? paymentMethod,
    String? paymentReference,
    required DateTime paymentDate,
    String? notes,
  }) async {
    try {
      final payment = await remoteDataSource.recordCustomerPayment(
        customerId: customerId,
        amount: amount,
        paymentMethod: paymentMethod,
        paymentReference: paymentReference,
        paymentDate: paymentDate,
        notes: notes,
      );
      return Result.right(payment);
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Payment>> recordSupplierPayment({
    required String supplierId,
    required double amount,
    PaymentMethod? paymentMethod,
    String? paymentReference,
    required DateTime paymentDate,
    String? notes,
  }) async {
    try {
      final payment = await remoteDataSource.recordSupplierPayment(
        supplierId: supplierId,
        amount: amount,
        paymentMethod: paymentMethod,
        paymentReference: paymentReference,
        paymentDate: paymentDate,
        notes: notes,
      );
      return Result.right(payment);
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<PaymentMetrics>> getMetrics() async {
    try {
      final raw = await remoteDataSource.getMetricsRaw();
      return Result.right(PaymentMetrics(
        totalReceivedThisMonth: (raw['total_received'] as num).toDouble(),
        totalPaidOutThisMonth: (raw['total_paid_out'] as num).toDouble(),
        paymentsCountThisMonth: raw['count'] as int,
      ));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }
}
