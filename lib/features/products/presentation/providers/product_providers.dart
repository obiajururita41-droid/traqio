import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/config/supabase_config.dart';
import 'package:traqio/features/products/data/datasources/product_remote_datasource.dart';
import 'package:traqio/features/products/data/repositories/product_repository_impl.dart';
import 'package:traqio/features/products/domain/entities/product.dart';
import 'package:traqio/features/products/domain/repositories/product_repository.dart';
import 'package:traqio/features/products/domain/usecases/product_usecases.dart';

final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  return ProductRemoteDataSource(SupabaseConfig.client);
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(ref.watch(productRemoteDataSourceProvider));
});

final getProductsUseCaseProvider = Provider((ref) {
  return GetProductsUseCase(ref.watch(productRepositoryProvider));
});

final getProductByIdUseCaseProvider = Provider((ref) {
  return GetProductByIdUseCase(ref.watch(productRepositoryProvider));
});

final createProductUseCaseProvider = Provider((ref) {
  return CreateProductUseCase(ref.watch(productRepositoryProvider));
});

final updateProductUseCaseProvider = Provider((ref) {
  return UpdateProductUseCase(ref.watch(productRepositoryProvider));
});

final deleteProductUseCaseProvider = Provider((ref) {
  return DeleteProductUseCase(ref.watch(productRepositoryProvider));
});

final searchProductsUseCaseProvider = Provider((ref) {
  return SearchProductsUseCase(ref.watch(productRepositoryProvider));
});

final getLowStockProductsUseCaseProvider = Provider((ref) {
  return GetLowStockProductsUseCase(ref.watch(productRepositoryProvider));
});

/// Search query state — drives the product list screen's search bar.
final productSearchQueryProvider = StateProvider<String>((ref) => '');

/// Main product list. Re-fetches whenever invalidated (e.g. after
/// create/update/delete).
final productsProvider = FutureProvider<List<Product>>((ref) async {
  final query = ref.watch(productSearchQueryProvider);
  if (query.trim().isEmpty) {
    final result = await ref.watch(getProductsUseCaseProvider)();
    return result.match((failure) => throw failure, (data) => data);
  } else {
    final result = await ref.watch(searchProductsUseCaseProvider)(query);
    return result.match((failure) => throw failure, (data) => data);
  }
});

final singleProductProvider =
    FutureProvider.family<Product, String>((ref, id) async {
  final result = await ref.watch(getProductByIdUseCaseProvider)(id);
  return result.match((failure) => throw failure, (data) => data);
});
