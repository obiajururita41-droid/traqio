import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/suppliers/domain/entities/supplier.dart';
import 'package:traqio/features/suppliers/domain/entities/supplier_enums.dart';
import 'package:traqio/features/suppliers/domain/entities/supplier_ledger_entry.dart';
import 'package:traqio/features/suppliers/domain/repositories/supplier_repository.dart';

class GetSuppliersUseCase {
  final SupplierRepository repository;
  const GetSuppliersUseCase(this.repository);
  Future<Result<List<Supplier>>> call() => repository.getSuppliers();
}

class GetSupplierByIdUseCase {
  final SupplierRepository repository;
  const GetSupplierByIdUseCase(this.repository);
  Future<Result<Supplier>> call(String id) => repository.getSupplierById(id);
}

class CreateSupplierUseCase {
  final SupplierRepository repository;
  const CreateSupplierUseCase(this.repository);
  Future<Result<Supplier>> call(Supplier supplier) => repository.createSupplier(supplier);
}

class UpdateSupplierUseCase {
  final SupplierRepository repository;
  const UpdateSupplierUseCase(this.repository);
  Future<Result<Supplier>> call(Supplier supplier) => repository.updateSupplier(supplier);
}

class DeleteSupplierUseCase {
  final SupplierRepository repository;
  const DeleteSupplierUseCase(this.repository);
  Future<Result<void>> call(String id) => repository.deleteSupplier(id);
}

class SearchSuppliersUseCase {
  final SupplierRepository repository;
  const SearchSuppliersUseCase(this.repository);
  Future<Result<List<Supplier>>> call(String query) => repository.searchSuppliers(query);
}

class PostSupplierLedgerEntryUseCase {
  final SupplierRepository repository;
  const PostSupplierLedgerEntryUseCase(this.repository);
  Future<Result<SupplierLedgerEntry>> call({
    required String supplierId,
    required SupplierLedgerEntryType entryType,
    required SupplierLedgerDirection direction,
    required double amount,
    String? referenceType,
    String? referenceId,
    String? notes,
  }) {
    return repository.postLedgerEntry(
      supplierId: supplierId,
      entryType: entryType,
      direction: direction,
      amount: amount,
      referenceType: referenceType,
      referenceId: referenceId,
      notes: notes,
    );
  }
}

class GetSupplierLedgerUseCase {
  final SupplierRepository repository;
  const GetSupplierLedgerUseCase(this.repository);
  Future<Result<List<SupplierLedgerEntry>>> call(String supplierId) =>
      repository.getSupplierLedger(supplierId);
}
