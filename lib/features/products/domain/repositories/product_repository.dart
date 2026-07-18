import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/products/domain/entities/product.dart';

abstract class ProductRepository {
  Future<Result<List<Product>>> getProducts();
  Future<Result<Product>> getProductById(String id);
  Future<Result<Product>> createProduct(Product product);
  Future<Result<Product>> updateProduct(Product product);
  Future<Result<void>> deleteProduct(String id);
  Future<Result<List<Product>>> searchProducts(String query);
  Future<Result<List<Product>>> getLowStockProducts();
}
