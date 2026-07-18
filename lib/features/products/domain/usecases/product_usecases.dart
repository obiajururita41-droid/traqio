import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/products/domain/entities/product.dart';
import 'package:traqio/features/products/domain/repositories/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository repository;
  const GetProductsUseCase(this.repository);
  Future<Result<List<Product>>> call() => repository.getProducts();
}

class GetProductByIdUseCase {
  final ProductRepository repository;
  const GetProductByIdUseCase(this.repository);
  Future<Result<Product>> call(String id) => repository.getProductById(id);
}

class CreateProductUseCase {
  final ProductRepository repository;
  const CreateProductUseCase(this.repository);
  Future<Result<Product>> call(Product product) =>
      repository.createProduct(product);
}

class UpdateProductUseCase {
  final ProductRepository repository;
  const UpdateProductUseCase(this.repository);
  Future<Result<Product>> call(Product product) =>
      repository.updateProduct(product);
}

class DeleteProductUseCase {
  final ProductRepository repository;
  const DeleteProductUseCase(this.repository);
  Future<Result<void>> call(String id) => repository.deleteProduct(id);
}

class SearchProductsUseCase {
  final ProductRepository repository;
  const SearchProductsUseCase(this.repository);
  Future<Result<List<Product>>> call(String query) =>
      repository.searchProducts(query);
}

class GetLowStockProductsUseCase {
  final ProductRepository repository;
  const GetLowStockProductsUseCase(this.repository);
  Future<Result<List<Product>>> call() => repository.getLowStockProducts();
}
