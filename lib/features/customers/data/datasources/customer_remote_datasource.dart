import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:traqio/core/errors/exceptions.dart';
import 'package:traqio/features/customers/data/models/customer_model.dart';
import 'package:traqio/features/customers/data/models/ledger_entry_model.dart';
import 'package:traqio/features/customers/domain/entities/customer.dart';
import 'package:traqio/features/customers/domain/entities/customer_enums.dart';

class CustomerRemoteDataSource {
  final SupabaseClient client;
  const CustomerRemoteDataSource(this.client);

  static const _customersTable = 'customers';
  static const _ledgerTable = 'customer_ledger_entries';

  String get _businessId {
    final id = client.auth.currentUser?.id;
    if (id == null) throw ServerException('No authenticated user.');
    return id;
  }

  Future<List<CustomerModel>> getCustomers() async {
    try {
      final rows = await client
          .from(_customersTable)
          .select()
          .eq('business_id', _businessId)
          .order('created_at', ascending: false);
      return (rows as List)
          .map((row) => CustomerModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<CustomerModel> getCustomerById(String id) async {
    try {
      final row = await client
          .from(_customersTable)
          .select()
          .eq('id', id)
          .eq('business_id', _businessId)
          .single();
      return CustomerModel.fromJson(row);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<CustomerModel> createCustomer(Customer customer) async {
    try {
      final payload = CustomerModel.fromEntity(customer).toJson()
        ..remove('id')
        ..remove('outstanding_balance') // always starts at 0, set by DB default
        ..['business_id'] = _businessId;
      final row = await client.from(_customersTable).insert(payload).select().single();
      return CustomerModel.fromJson(row);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<CustomerModel> updateCustomer(Customer customer) async {
    try {
      final payload = CustomerModel.fromEntity(customer).toJson()
        ..remove('outstanding_balance') // balance only changes via ledger RPC
        ..['updated_at'] = DateTime.now().toIso8601String();
      final row = await client
          .from(_customersTable)
          .update(payload)
          .eq('id', customer.id)
          .eq('business_id', _businessId)
          .select()
          .single();
      return CustomerModel.fromJson(row);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await client
          .from(_customersTable)
          .delete()
          .eq('id', id)
          .eq('business_id', _businessId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<List<CustomerModel>> searchCustomers(String query) async {
    try {
      final rows = await client
          .from(_customersTable)
          .select()
          .eq('business_id', _businessId)
          .or('name.ilike.%$query%,phone.ilike.%$query%,email.ilike.%$query%');
      return (rows as List)
          .map((row) => CustomerModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<LedgerEntryModel> postLedgerEntry({
    required String customerId,
    required LedgerEntryType entryType,
    required LedgerDirection direction,
    required double amount,
    String? referenceType,
    String? referenceId,
    String? notes,
  }) async {
    try {
      final row = await client.rpc('create_customer_ledger_entry', params: {
        'p_customer_id': customerId,
        'p_entry_type': entryType.dbValue,
        'p_direction': direction.dbValue,
        'p_amount': amount,
        'p_reference_type': referenceType,
        'p_reference_id': referenceId,
        'p_notes': notes,
      });
      return LedgerEntryModel.fromJson(row as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<List<LedgerEntryModel>> getCustomerLedger(String customerId) async {
    try {
      final rows = await client
          .from(_ledgerTable)
          .select()
          .eq('business_id', _businessId)
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);
      return (rows as List)
          .map((row) => LedgerEntryModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
