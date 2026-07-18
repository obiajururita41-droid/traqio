import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/config/supabase_config.dart';
import 'package:traqio/features/customers/data/datasources/customer_remote_datasource.dart';
import 'package:traqio/features/customers/data/repositories/customer_repository_impl.dart';
import 'package:traqio/features/customers/domain/entities/customer.dart';
import 'package:traqio/features/customers/domain/repositories/customer_repository.dart';
import 'package:traqio/features/customers/domain/usecases/customer_usecases.dart';

final customerRemoteDataSourceProvider = Provider<CustomerRemoteDataSource>((ref) {
  return CustomerRemoteDataSource(SupabaseConfig.client);
});

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepositoryImpl(ref.watch(customerRemoteDataSourceProvider));
});

final getCustomersUseCaseProvider = Provider((ref) {
  return GetCustomersUseCase(ref.watch(customerRepositoryProvider));
});

final getCustomerByIdUseCaseProvider = Provider((ref) {
  return GetCustomerByIdUseCase(ref.watch(customerRepositoryProvider));
});

final createCustomerUseCaseProvider = Provider((ref) {
  return CreateCustomerUseCase(ref.watch(customerRepositoryProvider));
});

final updateCustomerUseCaseProvider = Provider((ref) {
  return UpdateCustomerUseCase(ref.watch(customerRepositoryProvider));
});

final deleteCustomerUseCaseProvider = Provider((ref) {
  return DeleteCustomerUseCase(ref.watch(customerRepositoryProvider));
});

final searchCustomersUseCaseProvider = Provider((ref) {
  return SearchCustomersUseCase(ref.watch(customerRepositoryProvider));
});

final postLedgerEntryUseCaseProvider = Provider((ref) {
  return PostLedgerEntryUseCase(ref.watch(customerRepositoryProvider));
});

final getCustomerLedgerUseCaseProvider = Provider((ref) {
  return GetCustomerLedgerUseCase(ref.watch(customerRepositoryProvider));
});

final customerSearchQueryProvider = StateProvider<String>((ref) => '');

final customersProvider = FutureProvider<List<Customer>>((ref) async {
  final query = ref.watch(customerSearchQueryProvider);
  if (query.trim().isEmpty) {
    final result = await ref.watch(getCustomersUseCaseProvider)();
    return result.match((failure) => throw failure, (data) => data);
  } else {
    final result = await ref.watch(searchCustomersUseCaseProvider)(query);
    return result.match((failure) => throw failure, (data) => data);
  }
});

final singleCustomerProvider = FutureProvider.family<Customer, String>((ref, id) async {
  final result = await ref.watch(getCustomerByIdUseCaseProvider)(id);
  return result.match((failure) => throw failure, (data) => data);
});

final customerLedgerProvider = FutureProvider.family((ref, String customerId) async {
  final result = await ref.watch(getCustomerLedgerUseCaseProvider)(customerId);
  return result.match((failure) => throw failure, (data) => data);
});
