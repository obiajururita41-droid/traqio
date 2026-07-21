import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:traqio/core/enums/payment_method.dart';
import 'package:traqio/core/errors/exceptions.dart';
import 'package:traqio/features/invoices/data/models/invoice_model.dart';
import 'package:traqio/features/invoices/data/models/invoice_payment_model.dart';
import 'package:traqio/features/invoices/domain/entities/invoice_enums.dart';

class InvoiceRemoteDataSource {
  final SupabaseClient client;
  const InvoiceRemoteDataSource(this.client);

  static const _table = 'invoices';
  static const _paymentsTable = 'invoice_payments';
  static const _selectWithJoins =
      '*, customers(name), sales_orders(so_number), invoice_items(*)';

  String get _businessId {
    final id = client.auth.currentUser?.id;
    if (id == null) throw ServerException('No authenticated user.');
    return id;
  }

  Future<List<InvoiceModel>> getInvoices({
    InvoiceStatus? statusFilter,
    String? searchQuery,
    required int offset,
    required int limit,
    required bool newestFirst,
  }) async {
    try {
      var query = client
          .from(_table)
          .select(_selectWithJoins)
          .eq('business_id', _businessId);

      if (statusFilter != null) {
        query = query.eq('status', statusFilter.dbValue);
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        query = query.ilike('invoice_number', '%${searchQuery.trim()}%');
      }

      final rows = await query
          .order('issue_date', ascending: !newestFirst)
          .range(offset, offset + limit - 1);

      return (rows as List)
          .map((row) => InvoiceModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<InvoiceModel> getInvoiceById(String id) async {
    try {
      final row = await client
          .from(_table)
          .select(_selectWithJoins)
          .eq('id', id)
          .eq('business_id', _businessId)
          .single();
      return InvoiceModel.fromJson(row);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<InvoiceModel> generateFromSalesOrder({
    required String salesOrderId,
    required String invoiceNumber,
    DateTime? dueDate,
    String? notes,
  }) async {
    try {
      final row = await client.rpc('generate_invoice_from_sales_order', params: {
        'p_so_id': salesOrderId,
        'p_invoice_number': invoiceNumber,
        'p_due_date': dueDate?.toIso8601String(),
        'p_notes': notes,
      });
      final id = (row as Map<String, dynamic>)['id'] as String;
      return getInvoiceById(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<InvoiceModel> markAsSent(String id) async {
    try {
      await client.rpc('mark_invoice_sent', params: {'p_invoice_id': id});
      return getInvoiceById(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<InvoiceModel> cancelInvoice(String id) async {
    try {
      await client.rpc('cancel_invoice', params: {'p_invoice_id': id});
      return getInvoiceById(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<InvoiceModel> recordPayment({
    required String invoiceId,
    required double amount,
    PaymentMethod? paymentMethod,
    required DateTime paymentDate,
    String? notes,
  }) async {
    try {
      await client.rpc('record_invoice_payment', params: {
        'p_invoice_id': invoiceId,
        'p_amount': amount,
        'p_payment_method': paymentMethod?.dbValue,
        'p_payment_date': paymentDate.toIso8601String(),
        'p_notes': notes,
      });
      return getInvoiceById(invoiceId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<List<InvoicePaymentModel>> getInvoicePayments(String invoiceId) async {
    try {
      final rows = await client
          .from(_paymentsTable)
          .select()
          .eq('business_id', _businessId)
          .eq('invoice_id', invoiceId)
          .order('payment_date', ascending: false);
      return (rows as List)
          .map((row) => InvoicePaymentModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<Map<String, dynamic>> getMetricsRaw() async {
    try {
      final rows = await client
          .from(_table)
          .select('status, due_date, total_amount, paid_amount')
          .eq('business_id', _businessId)
          .not('status', 'in', '(paid,cancelled)');

      int outstandingCount = 0;
      double outstandingValue = 0;
      int overdueCount = 0;
      final now = DateTime.now();

      for (final row in rows as List) {
        final total = (row['total_amount'] as num?)?.toDouble() ?? 0;
        final paid = (row['paid_amount'] as num?)?.toDouble() ?? 0;
        outstandingCount++;
        outstandingValue += (total - paid);
        final due = row['due_date'];
        if (due != null && DateTime.parse(due as String).isBefore(now)) {
          overdueCount++;
        }
      }

      return {
        'outstanding_count': outstandingCount,
        'outstanding_value': outstandingValue,
        'overdue_count': overdueCount,
      };
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
