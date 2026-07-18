import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/errors/failures.dart';
import 'package:traqio/features/products/domain/entities/product.dart';
import 'package:traqio/features/products/presentation/providers/product_providers.dart';

sealed class ProductFormState {
  const ProductFormState();
}

class ProductFormInitial extends ProductFormState {
  const ProductFormInitial();
}

class ProductFormLoading extends ProductFormState {
  const ProductFormLoading();
}

class ProductFormSuccess extends ProductFormState {
  final Product product;
  const ProductFormSuccess(this.product);
}

class ProductFormError extends ProductFormState {
  final Failure failure;
  const ProductFormError(this.failure);
}

class ProductFormController extends StateNotifier<ProductFormState> {
  final Ref ref;
  ProductFormController(this.ref) : super(const ProductFormInitial());

  Future<void> create(Product product) async {
    state = const ProductFormLoading();
    final useCase = ref.read(createProductUseCaseProvider);
    final result = await useCase(product);
    result.match(
      (failure) => state = ProductFormError(failure),
      (created) {
        state = ProductFormSuccess(created);
        ref.invalidate(productsProvider);
      },
    );
  }

  Future<void> update(Product product) async {
    state = const ProductFormLoading();
    final useCase = ref.read(updateProductUseCaseProvider);
    final result = await useCase(product);
    result.match(
      (failure) => state = ProductFormError(failure),
      (updated) {
        state = ProductFormSuccess(updated);
        ref.invalidate(productsProvider);
      },
    );
  }

  Future<void> delete(String id) async {
    state = const ProductFormLoading();
    final useCase = ref.read(deleteProductUseCaseProvider);
    final result = await useCase(id);
    result.match(
      (failure) => state = ProductFormError(failure),
      (_) {
        state = const ProductFormInitial();
        ref.invalidate(productsProvider);
      },
    );
  }

  void reset() => state = const ProductFormInitial();
}

final productFormControllerProvider =
    StateNotifierProvider<ProductFormController, ProductFormState>((ref) {
  return ProductFormController(ref);
});
