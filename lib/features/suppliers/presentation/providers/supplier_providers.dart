import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/config/supabase_config.dart';
import 'package:traqio/features/suppliers/data/datasources/supplier_remote_datasource.dart';
import 'package:traqio/features/suppliers/data/repositories/supplier_repository_impl.dart';
import 'package:traqio/features/suppliers/domain/entities/supplier.dart';
import 'package:traqio/features/suppliers/domain/repositories/supplier_repository.dart';
import 'package:traqio/features/suppliers/domain/usecases/supplier_usecases.dart';

final supplierRemoteDataSourceProvider = Provider<SupplierRemoteDataSource>((ref) {
  return SupplierRemoteDataSource(SupabaseConfig.client);
});

final supplierRepositoryProvider = Provider<SupplierRepository>((ref) {
  return SupplierRepositoryImpl(ref.watch(supplierRemoteDataSourceProvider));
});

final getSuppliersUseCaseProvider = Provider((ref) {
  return GetSuppliersUseCase(ref.watch(supplierRepositoryProvider));
});

final getSupplierByIdUseCaseProvider = Provider((ref) {
  return GetSupplierByIdUseCase(ref.watch(supplierRepositoryProvider));
});

final createSupplierUseCaseProvider = Provider((ref) {
  return CreateSupplierUseCase(ref.watch(supplierRepositoryProvider));
});

final updateSupplierUseCaseProvider = Provider((ref) {
  return UpdateSupplierUseCase(ref.watch(supplierRepositoryProvider));
});

final deleteSupplierUseCaseProvider = Provider((ref) {
  return DeleteSupplierUseCase(ref.watch(supplierRepositoryProvider));
});

final searchSuppliersUseCaseProvider = Provider((ref) {
  return SearchSuppliersUseCase(ref.watch(supplierRepositoryProvider));
});

final postSupplierLedgerEntryUseCaseProvider = Provider((ref) {
  return PostSupplierLedgerEntryUseCase(ref.watch(supplierRepositoryProvider));
});

final getSupplierLedgerUseCaseProvider = Provider((ref) {
  return GetSupplierLedgerUseCase(ref.watch(supplierRepositoryProvider));
});

final supplierSearchQueryProvider = StateProvider<String>((ref) => '');

final suppliersProvider = FutureProvider<List<Supplier>>((ref) async {
  final query = ref.watch(supplierSearchQueryProvider);
  if (query.trim().isEmpty) {
    final result = await ref.watch(getSuppliersUseCaseProvider)();
    return result.match((failure) => throw failure, (data) => data);
  } else {
    final result = await ref.watch(searchSuppliersUseCaseProvider)(query);
    return result.match((failure) => throw failure, (data) => data);
  }
});

final singleSupplierProvider = FutureProvider.family<Supplier, String>((ref, id) async {
  final result = await ref.watch(getSupplierByIdUseCaseProvider)(id);
  return result.match((failure) => throw failure, (data) => data);
});

final supplierLedgerProvider = FutureProvider.family((ref, String supplierId) async {
  final result = await ref.watch(getSupplierLedgerUseCaseProvider)(supplierId);
  return result.match((failure) => throw failure, (data) => data);
});
