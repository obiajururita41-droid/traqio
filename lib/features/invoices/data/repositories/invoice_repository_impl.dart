import 'package:traqio/core/errors/failures.dart';
import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/invoices/data/datasources/invoice_remote_datasource.dart';
import 'package:traqio/features/invoices/domain/entities/invoice.dart';
import 'package:traqio/features/invoices/domain/entities/invoice_enums.dart';
import 'package:traqio/features/invoices/domain/entities/invoice_metrics.dart';
import 'package:traqio/features/invoices/domain/entities/invoice_payment.dart';
import 'package:traqio/features/invoices/domain/repositories/invoice_repository.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final InvoiceRemoteDataSource remoteDataSource;
  const InvoiceRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<Invoice>>> getInvoices({
    InvoiceStatus? statusFilter,
    String? searchQuery,
    required int offset,
    required int limit,
    required bool newestFirst,
  }) async {
    try {
      final invoices = await remoteDataSource.getInvoices(
        statusFilter: statusFilter,
        searchQuery: searchQuery,
        offset: offset,
        limit: limit,
        newestFirst: newestFirst,
      );
      return Result.right(invoices);
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Invoice>> getInvoiceById(String id) async {
    try {
      return Result.right(await remoteDataSource.getInvoiceById(id));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Invoice>> generateFromSalesOrder({
    required String salesOrderId,
    required String invoiceNumber,
    DateTime? dueDate,
    String? notes,
  }) async {
    try {
      final invoice = await remoteDataSource.generateFromSalesOrder(
        salesOrderId: salesOrderId,
        invoiceNumber: invoiceNumber,
        dueDate: dueDate,
        notes: notes,
      );
      return Result.right(invoice);
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Invoice>> markAsSent(String id) async {
    try {
      return Result.right(await remoteDataSource.markAsSent(id));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Invoice>> cancelInvoice(String id) async {
    try {
      return Result.right(await remoteDataSource.cancelInvoice(id));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Invoice>> recordPayment({
    required String invoiceId,
    required double amount,
    PaymentMethod? paymentMethod,
    required DateTime paymentDate,
    String? notes,
  }) async {
    try {
      final invoice = await remoteDataSource.recordPayment(
        invoiceId: invoiceId,
        amount: amount,
        paymentMethod: paymentMethod,
        paymentDate: paymentDate,
        notes: notes,
      );
      return Result.right(invoice);
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<InvoicePayment>>> getInvoicePayments(String invoiceId) async {
    try {
      return Result.right(await remoteDataSource.getInvoicePayments(invoiceId));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<InvoiceMetrics>> getMetrics() async {
    try {
      final raw = await remoteDataSource.getMetricsRaw();
      return Result.right(InvoiceMetrics(
        outstandingCount: raw['outstanding_count'] as int,
        outstandingValue: (raw['outstanding_value'] as num).toDouble(),
        overdueCount: raw['overdue_count'] as int,
      ));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }
}
