import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/invoices/domain/entities/invoice.dart';
import 'package:traqio/features/invoices/domain/entities/invoice_enums.dart';
import 'package:traqio/features/invoices/domain/entities/invoice_metrics.dart';
import 'package:traqio/features/invoices/domain/entities/invoice_payment.dart';

abstract class InvoiceRepository {
  Future<Result<List<Invoice>>> getInvoices({
    InvoiceStatus? statusFilter,
    String? searchQuery,
    required int offset,
    required int limit,
    required bool newestFirst,
  });

  Future<Result<Invoice>> getInvoiceById(String id);

  Future<Result<Invoice>> generateFromSalesOrder({
    required String salesOrderId,
    required String invoiceNumber,
    DateTime? dueDate,
    String? notes,
  });

  Future<Result<Invoice>> markAsSent(String id);
  Future<Result<Invoice>> cancelInvoice(String id);

  Future<Result<Invoice>> recordPayment({
    required String invoiceId,
    required double amount,
    PaymentMethod? paymentMethod,
    required DateTime paymentDate,
    String? notes,
  });

  Future<Result<List<InvoicePayment>>> getInvoicePayments(String invoiceId);

  Future<Result<InvoiceMetrics>> getMetrics();
}
