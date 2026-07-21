import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:traqio/core/enums/payment_method.dart';
import 'package:traqio/core/errors/exceptions.dart';
import 'package:traqio/features/payments/data/models/payment_model.dart';
import 'package:traqio/features/payments/domain/entities/payment_enums.dart';

class PaymentRemoteDataSource {
  final SupabaseClient client;
  final String businessId;
  const PaymentRemoteDataSource(this.client, this.businessId);

  static const _table = 'payments';
  static const _selectWithJoins =
      '*, customers(name), suppliers(name), invoices(invoice_number)';


  Future<List<PaymentModel>> getPayments({
    PaymentType? typeFilter,
    String? searchQuery,
    required int offset,
    required int limit,
    required bool newestFirst,
  }) async {
    try {
      var query = client
          .from(_table)
          .select(_selectWithJoins)
          .eq('business_id', businessId);

      if (typeFilter != null) {
        query = query.eq('payment_type', typeFilter.dbValue);
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        query = query.or(
          'payment_number.ilike.%${searchQuery.trim()}%,payment_reference.ilike.%${searchQuery.trim()}%',
        );
      }

      final rows = await query
          .order('payment_date', ascending: !newestFirst)
          .range(offset, offset + limit - 1);

      return (rows as List)
          .map((row) => PaymentModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<PaymentModel> getPaymentById(String id) async {
    try {
      final row = await client
          .from(_table)
          .select(_selectWithJoins)
          .eq('id', id)
          .eq('business_id', businessId)
          .single();
      return PaymentModel.fromJson(row);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<PaymentModel> recordCustomerPayment({
    required String customerId,
    required double amount,
    PaymentMethod? paymentMethod,
    String? paymentReference,
    required DateTime paymentDate,
    String? notes,
  }) async {
    try {
      final row = await client.rpc('record_customer_payment', params: {
        'p_business_id': businessId,
        'p_customer_id': customerId,
        'p_amount': amount,
        'p_payment_method': paymentMethod?.dbValue,
        'p_payment_reference': paymentReference,
        'p_payment_date': paymentDate.toIso8601String(),
        'p_notes': notes,
      });
      final id = (row as Map<String, dynamic>)['id'] as String;
      return getPaymentById(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<PaymentModel> recordSupplierPayment({
    required String supplierId,
    required double amount,
    PaymentMethod? paymentMethod,
    String? paymentReference,
    required DateTime paymentDate,
    String? notes,
  }) async {
    try {
      final row = await client.rpc('record_supplier_payment', params: {
        'p_business_id': businessId,
        'p_supplier_id': supplierId,
        'p_amount': amount,
        'p_payment_method': paymentMethod?.dbValue,
        'p_payment_reference': paymentReference,
        'p_payment_date': paymentDate.toIso8601String(),
        'p_notes': notes,
      });
      final id = (row as Map<String, dynamic>)['id'] as String;
      return getPaymentById(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<Map<String, dynamic>> getMetricsRaw() async {
    try {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1).toIso8601String();

      final rows = await client
          .from(_table)
          .select('payment_type, amount')
          .eq('business_id', businessId)
          .gte('payment_date', monthStart);

      double received = 0;
      double paidOut = 0;
      final list = rows as List;

      for (final row in list) {
        final amount = (row['amount'] as num).toDouble();
        final type = row['payment_type'] as String;
        if (type == 'customer_receipt') {
          received += amount;
        } else if (type == 'supplier_payment') {
          paidOut += amount;
        }
      }

      return {
        'total_received': received,
        'total_paid_out': paidOut,
        'count': list.length,
      };
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
