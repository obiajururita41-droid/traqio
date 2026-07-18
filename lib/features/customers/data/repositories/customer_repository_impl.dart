import 'package:traqio/core/errors/failures.dart';
import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/customers/data/datasources/customer_remote_datasource.dart';
import 'package:traqio/features/customers/domain/entities/customer.dart';
import 'package:traqio/features/customers/domain/entities/customer_enums.dart';
import 'package:traqio/features/customers/domain/entities/customer_ledger_entry.dart';
import 'package:traqio/features/customers/domain/repositories/customer_repository.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource remoteDataSource;
  const CustomerRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<Customer>>> getCustomers() async {
    try {
      return Result.right(await remoteDataSource.getCustomers());
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Customer>> getCustomerById(String id) async {
    try {
      return Result.right(await remoteDataSource.getCustomerById(id));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Customer>> createCustomer(Customer customer) async {
    try {
      return Result.right(await remoteDataSource.createCustomer(customer));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Customer>> updateCustomer(Customer customer) async {
    try {
      return Result.right(await remoteDataSource.updateCustomer(customer));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteCustomer(String id) async {
    try {
      await remoteDataSource.deleteCustomer(id);
      return Result.right(null);
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Customer>>> searchCustomers(String query) async {
    try {
      return Result.right(await remoteDataSource.searchCustomers(query));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<CustomerLedgerEntry>> postLedgerEntry({
    required String customerId,
    required LedgerEntryType entryType,
    required LedgerDirection direction,
    required double amount,
    String? referenceType,
    String? referenceId,
    String? notes,
  }) async {
    try {
      final entry = await remoteDataSource.postLedgerEntry(
        customerId: customerId,
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
  Future<Result<List<CustomerLedgerEntry>>> getCustomerLedger(String customerId) async {
    try {
      return Result.right(await remoteDataSource.getCustomerLedger(customerId));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }
}
