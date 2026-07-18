import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/suppliers/domain/entities/supplier.dart';
import 'package:traqio/features/suppliers/domain/entities/supplier_enums.dart';
import 'package:traqio/features/suppliers/domain/entities/supplier_ledger_entry.dart';

abstract class SupplierRepository {
  Future<Result<List<Supplier>>> getSuppliers();
  Future<Result<Supplier>> getSupplierById(String id);
  Future<Result<Supplier>> createSupplier(Supplier supplier);
  Future<Result<Supplier>> updateSupplier(Supplier supplier);
  Future<Result<void>> deleteSupplier(String id);
  Future<Result<List<Supplier>>> searchSuppliers(String query);

  Future<Result<SupplierLedgerEntry>> postLedgerEntry({
    required String supplierId,
    required SupplierLedgerEntryType entryType,
    required SupplierLedgerDirection direction,
    required double amount,
    String? referenceType,
    String? referenceId,
    String? notes,
  });

  Future<Result<List<SupplierLedgerEntry>>> getSupplierLedger(String supplierId);
}
