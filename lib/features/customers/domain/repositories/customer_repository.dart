import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/customers/domain/entities/customer.dart';
import 'package:traqio/features/customers/domain/entities/customer_enums.dart';
import 'package:traqio/features/customers/domain/entities/customer_ledger_entry.dart';

abstract class CustomerRepository {
  Future<Result<List<Customer>>> getCustomers();
  Future<Result<Customer>> getCustomerById(String id);
  Future<Result<Customer>> createCustomer(Customer customer);
  Future<Result<Customer>> updateCustomer(Customer customer);
  Future<Result<void>> deleteCustomer(String id);
  Future<Result<List<Customer>>> searchCustomers(String query);

  /// Posts a ledger entry AND updates the customer's balance
  /// atomically via RPC. Sales Orders, Invoices, and Payments will
  /// all call this — never update outstanding_balance directly.
  Future<Result<CustomerLedgerEntry>> postLedgerEntry({
    required String customerId,
    required LedgerEntryType entryType,
    required LedgerDirection direction,
    required double amount,
    String? referenceType,
    String? referenceId,
    String? notes,
  });

  Future<Result<List<CustomerLedgerEntry>>> getCustomerLedger(String customerId);
}
