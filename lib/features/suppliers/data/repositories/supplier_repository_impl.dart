import 'package:traqio/core/errors/failures.dart';
import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/suppliers/data/datasources/supplier_remote_datasource.dart';
import 'package:traqio/features/suppliers/domain/entities/supplier.dart';
import 'package:traqio/features/suppliers/domain/entities/supplier_enums.dart';
import 'package:traqio/features/suppliers/domain/entities/supplier_ledger_entry.dart';
import 'package:traqio/features/suppliers/domain/repositories/supplier_repository.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final SupplierRemoteDataSource remoteDataSource;
  const SupplierRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<Supplier>>> getSuppliers() async {
    try {
      return Result.right(await remoteDataSource.getSuppliers());
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Supplier>> getSupplierById(String id) async {
    try {
      return Result.right(await remoteDataSource.getSupplierById(id));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Supplier>> createSupplier(Supplier supplier) async {
    try {
      return Result.right(await remoteDataSource.createSupplier(supplier));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Supplier>> updateSupplier(Supplier supplier) async {
    try {
      return Result.right(await remoteDataSource.updateSupplier(supplier));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteSupplier(String id) async {
    try {
      await remoteDataSource.deleteSupplier(id);
      return Result.right(null);
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Supplier>>> searchSuppliers(String query) async {
    try {
      return Result.right(await remoteDataSource.searchSuppliers(query));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<SupplierLedgerEntry>> postLedgerEntry({
    required String supplierId,
    required SupplierLedgerEntryType entryType,
    required SupplierLedgerDirection direction,
    required double amount,
    String? referenceType,
    String? referenceId,
    String? notes,
  }) async {
    try {
      final entry = await remoteDataSource.postLedgerEntry(
        supplierId: supplierId,
        entryType: entryType,
        direction: direction,
        amount: amount,
        referenceType: referenceType,
        referenceId: referenceId,
        notes: notes,
      );
      return Result.right(entry);
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<SupplierLedgerEntry>>> getSupplierLedger(String supplierId) async {
    try {
      return Result.right(await remoteDataSource.getSupplierLedger(supplierId));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }
}
