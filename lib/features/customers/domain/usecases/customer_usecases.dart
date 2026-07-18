import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/customers/domain/entities/customer.dart';
import 'package:traqio/features/customers/domain/entities/customer_enums.dart';
import 'package:traqio/features/customers/domain/entities/customer_ledger_entry.dart';
import 'package:traqio/features/customers/domain/repositories/customer_repository.dart';

class GetCustomersUseCase {
  final CustomerRepository repository;
  const GetCustomersUseCase(this.repository);
  Future<Result<List<Customer>>> call() => repository.getCustomers();
}

class GetCustomerByIdUseCase {
  final CustomerRepository repository;
  const GetCustomerByIdUseCase(this.repository);
  Future<Result<Customer>> call(String id) => repository.getCustomerById(id);
}

class CreateCustomerUseCase {
  final CustomerRepository repository;
  const CreateCustomerUseCase(this.repository);
  Future<Result<Customer>> call(Customer customer) => repository.createCustomer(customer);
}

class UpdateCustomerUseCase {
  final CustomerRepository repository;
  const UpdateCustomerUseCase(this.repository);
  Future<Result<Customer>> call(Customer customer) => repository.updateCustomer(customer);
}

class DeleteCustomerUseCase {
  final CustomerRepository repository;
  const DeleteCustomerUseCase(this.repository);
  Future<Result<void>> call(String id) => repository.deleteCustomer(id);
}

class SearchCustomersUseCase {
  final CustomerRepository repository;
  const SearchCustomersUseCase(this.repository);
  Future<Result<List<Customer>>> call(String query) => repository.searchCustomers(query);
}

class PostLedgerEntryUseCase {
  final CustomerRepository repository;
  const PostLedgerEntryUseCase(this.repository);
  Future<Result<CustomerLedgerEntry>> call({
    required String customerId,
    required LedgerEntryType entryType,
    required LedgerDirection direction,
    required double amount,
    String? referenceType,
    String? referenceId,
    String? notes,
  }) {
    return repository.postLedgerEntry(
      customerId: customerId,
      entryType: entryType,
      direction: direction,
      amount: amount,
      referenceType: referenceType,
      referenceId: referenceId,
      notes: notes,
    );
  }
}

class GetCustomerLedgerUseCase {
  final CustomerRepository repository;
  const GetCustomerLedgerUseCase(this.repository);
  Future<Result<List<CustomerLedgerEntry>>> call(String customerId) =>
      repository.getCustomerLedger(customerId);
}
