import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/invoices/domain/entities/invoice.dart';
import 'package:traqio/features/invoices/domain/entities/invoice_enums.dart';
import 'package:traqio/features/invoices/domain/entities/invoice_metrics.dart';
import 'package:traqio/features/invoices/domain/entities/invoice_payment.dart';
import 'package:traqio/features/invoices/domain/repositories/invoice_repository.dart';

class GetInvoicesUseCase {
  final InvoiceRepository repository;
  const GetInvoicesUseCase(this.repository);
  Future<Result<List<Invoice>>> call({
    InvoiceStatus? statusFilter,
    String? searchQuery,
    required int offset,
    required int limit,
    required bool newestFirst,
  }) {
    return repository.getInvoices(
      statusFilter: statusFilter,
      searchQuery: searchQuery,
      offset: offset,
      limit: limit,
      newestFirst: newestFirst,
    );
  }
}

class GetInvoiceByIdUseCase {
  final InvoiceRepository repository;
  const GetInvoiceByIdUseCase(this.repository);
  Future<Result<Invoice>> call(String id) => repository.getInvoiceById(id);
}

class GenerateInvoiceFromSalesOrderUseCase {
  final InvoiceRepository repository;
  const GenerateInvoiceFromSalesOrderUseCase(this.repository);
  Future<Result<Invoice>> call({
    required String salesOrderId,
    required String invoiceNumber,
    DateTime? dueDate,
    String? notes,
  }) {
    return repository.generateFromSalesOrder(
      salesOrderId: salesOrderId,
      invoiceNumber: invoiceNumber,
      dueDate: dueDate,
      notes: notes,
    );
  }
}

class MarkInvoiceAsSentUseCase {
  final InvoiceRepository repository;
  const MarkInvoiceAsSentUseCase(this.repository);
  Future<Result<Invoice>> call(String id) => repository.markAsSent(id);
}

class CancelInvoiceUseCase {
  final InvoiceRepository repository;
  const CancelInvoiceUseCase(this.repository);
  Future<Result<Invoice>> call(String id) => repository.cancelInvoice(id);
}

class RecordInvoicePaymentUseCase {
  final InvoiceRepository repository;
  const RecordInvoicePaymentUseCase(this.repository);
  Future<Result<Invoice>> call({
    required String invoiceId,
    required double amount,
    PaymentMethod? paymentMethod,
    required DateTime paymentDate,
    String? notes,
  }) {
    return repository.recordPayment(
      invoiceId: invoiceId,
      amount: amount,
      paymentMethod: paymentMethod,
      paymentDate: paymentDate,
      notes: notes,
    );
  }
}

class GetInvoicePaymentsUseCase {
  final InvoiceRepository repository;
  const GetInvoicePaymentsUseCase(this.repository);
  Future<Result<List<InvoicePayment>>> call(String invoiceId) =>
      repository.getInvoicePayments(invoiceId);
}

class GetInvoiceMetricsUseCase {
  final InvoiceRepository repository;
  const GetInvoiceMetricsUseCase(this.repository);
  Future<Result<InvoiceMetrics>> call() => repository.getMetrics();
}
