import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/errors/failures.dart';
import 'package:traqio/features/customers/domain/entities/customer.dart';
import 'package:traqio/features/customers/presentation/providers/customer_providers.dart';

sealed class CustomerFormState {
  const CustomerFormState();
}

class CustomerFormInitial extends CustomerFormState {
  const CustomerFormInitial();
}

class CustomerFormLoading extends CustomerFormState {
  const CustomerFormLoading();
}

class CustomerFormSuccess extends CustomerFormState {
  final Customer customer;
  const CustomerFormSuccess(this.customer);
}

class CustomerFormError extends CustomerFormState {
  final Failure failure;
  const CustomerFormError(this.failure);
}

class CustomerFormController extends StateNotifier<CustomerFormState> {
  final Ref ref;
  CustomerFormController(this.ref) : super(const CustomerFormInitial());

  Future<void> create(Customer customer) async {
    state = const CustomerFormLoading();
    final useCase = ref.read(createCustomerUseCaseProvider);
    final result = await useCase(customer);
    result.match(
      (failure) => state = CustomerFormError(failure),
      (created) {
        state = CustomerFormSuccess(created);
        ref.invalidate(customersProvider);
      },
    );
  }

  Future<void> update(Customer customer) async {
    state = const CustomerFormLoading();
    final useCase = ref.read(updateCustomerUseCaseProvider);
    final result = await useCase(customer);
    result.match(
      (failure) => state = CustomerFormError(failure),
      (updated) {
        state = CustomerFormSuccess(updated);
        ref.invalidate(customersProvider);
      },
    );
  }

  Future<void> delete(String id) async {
    state = const CustomerFormLoading();
    final useCase = ref.read(deleteCustomerUseCaseProvider);
    final result = await useCase(id);
    result.match(
      (failure) => state = CustomerFormError(failure),
      (_) {
        state = const CustomerFormInitial();
        ref.invalidate(customersProvider);
      },
    );
  }

  void reset() => state = const CustomerFormInitial();
}

final customerFormControllerProvider =
    StateNotifierProvider<CustomerFormController, CustomerFormState>((ref) {
  return CustomerFormController(ref);
});
