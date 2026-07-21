import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:traqio/core/errors/exceptions.dart';
import 'package:traqio/features/suppliers/data/models/supplier_ledger_entry_model.dart';
import 'package:traqio/features/suppliers/data/models/supplier_model.dart';
import 'package:traqio/features/suppliers/domain/entities/supplier.dart';
import 'package:traqio/features/suppliers/domain/entities/supplier_enums.dart';

class SupplierRemoteDataSource {
  final SupabaseClient client;
  final String businessId;
  const SupplierRemoteDataSource(this.client, this.businessId);

  static const _suppliersTable = 'suppliers';
  static const _ledgerTable = 'supplier_ledger_entries';


  Future<List<SupplierModel>> getSuppliers() async {
    try {
      final rows = await client
          .from(_suppliersTable)
          .select()
          .eq('business_id', businessId)
          .order('created_at', ascending: false);
      return (rows as List)
          .map((row) => SupplierModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<SupplierModel> getSupplierById(String id) async {
    try {
      final row = await client
          .from(_suppliersTable)
          .select()
          .eq('id', id)
          .eq('business_id', businessId)
          .single();
      return SupplierModel.fromJson(row);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<SupplierModel> createSupplier(Supplier supplier) async {
    try {
      final payload = SupplierModel.fromEntity(supplier).toJson()
        ..remove('id')
        ..remove('outstanding_balance')
        ..['business_id'] = businessId;
      final row = await client.from(_suppliersTable).insert(payload).select().single();
      return SupplierModel.fromJson(row);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<SupplierModel> updateSupplier(Supplier supplier) async {
    try {
      final payload = SupplierModel.fromEntity(supplier).toJson()
        ..remove('outstanding_balance')
        ..['updated_at'] = DateTime.now().toIso8601String();
      final row = await client
          .from(_suppliersTable)
          .update(payload)
          .eq('id', supplier.id)
          .eq('business_id', businessId)
          .select()
          .single();
      return SupplierModel.fromJson(row);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> deleteSupplier(String id) async {
    try {
      await client
          .from(_suppliersTable)
          .delete()
          .eq('id', id)
          .eq('business_id', businessId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<List<SupplierModel>> searchSuppliers(String query) async {
    try {
      final rows = await client
          .from(_suppliersTable)
          .select()
          .eq('business_id', businessId)
          .or('name.ilike.%$query%,phone.ilike.%$query%,email.ilike.%$query%,contact_person.ilike.%$query%');
      return (rows as List)
          .map((row) => SupplierModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<SupplierLedgerEntryModel> postLedgerEntry({
    required String supplierId,
    required SupplierLedgerEntryType entryType,
    required SupplierLedgerDirection direction,
    required double amount,
    String? referenceType,
    String? referenceId,
    String? notes,
  }) async {
    try {
      final row = await client.rpc('create_supplier_ledger_entry', params: {
        'p_business_id': businessId,
        'p_supplier_id': supplierId,
        'p_entry_type': entryType.dbValue,
        'p_direction': direction.dbValue,
        'p_amount': amount,
        'p_reference_type': referenceType,
        'p_reference_id': referenceId,
        'p_notes': notes,
      });
      return SupplierLedgerEntryModel.fromJson(row as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<List<SupplierLedgerEntryModel>> getSupplierLedger(String supplierId) async {
    try {
      final rows = await client
          .from(_ledgerTable)
          .select()
          .eq('business_id', businessId)
          .eq('supplier_id', supplierId)
          .order('created_at', ascending: false);
      return (rows as List)
          .map((row) => SupplierLedgerEntryModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
