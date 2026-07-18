import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/errors/failures.dart';
import 'package:traqio/features/suppliers/domain/entities/supplier.dart';
import 'package:traqio/features/suppliers/presentation/providers/supplier_providers.dart';

sealed class SupplierFormState {
  const SupplierFormState();
}

class SupplierFormInitial extends SupplierFormState {
  const SupplierFormInitial();
}

class SupplierFormLoading extends SupplierFormState {
  const SupplierFormLoading();
}

class SupplierFormSuccess extends SupplierFormState {
  final Supplier supplier;
  const SupplierFormSuccess(this.supplier);
}

class SupplierFormError extends SupplierFormState {
  final Failure failure;
  const SupplierFormError(this.failure);
}

class SupplierFormController extends StateNotifier<SupplierFormState> {
  final Ref ref;
  SupplierFormController(this.ref) : super(const SupplierFormInitial());

  Future<void> create(Supplier supplier) async {
    state = const SupplierFormLoading();
    final useCase = ref.read(createSupplierUseCaseProvider);
    final result = await useCase(supplier);
    result.match(
      (failure) => state = SupplierFormError(failure),
      (created) {
        state = SupplierFormSuccess(created);
        ref.invalidate(suppliersProvider);
      },
    );
  }

  Future<void> update(Supplier supplier) async {
    state = const SupplierFormLoading();
    final useCase = ref.read(updateSupplierUseCaseProvider);
    final result = await useCase(supplier);
    result.match(
      (failure) => state = SupplierFormError(failure),
      (updated) {
        state = SupplierFormSuccess(updated);
        ref.invalidate(suppliersProvider);
      },
    );
  }

  Future<void> delete(String id) async {
    state = const SupplierFormLoading();
    final useCase = ref.read(deleteSupplierUseCaseProvider);
    final result = await useCase(id);
    result.match(
      (failure) => state = SupplierFormError(failure),
      (_) {
        state = const SupplierFormInitial();
        ref.invalidate(suppliersProvider);
      },
    );
  }

  void reset() => state = const SupplierFormInitial();
}

final supplierFormControllerProvider =
    StateNotifierProvider<SupplierFormController, SupplierFormState>((ref) {
  return SupplierFormController(ref);
});
