import 'package:traqio/core/errors/failures.dart';
import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/products/data/datasources/product_remote_datasource.dart';
import 'package:traqio/features/products/domain/entities/product.dart';
import 'package:traqio/features/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  const ProductRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<Product>>> getProducts() async {
    try {
      return Result.right(await remoteDataSource.getProducts());
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Product>> getProductById(String id) async {
    try {
      return Result.right(await remoteDataSource.getProductById(id));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Product>> createProduct(Product product) async {
    try {
      return Result.right(await remoteDataSource.createProduct(product));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Product>> updateProduct(Product product) async {
    try {
      return Result.right(await remoteDataSource.updateProduct(product));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteProduct(String id) async {
    try {
      await remoteDataSource.deleteProduct(id);
      return Result.right(null);
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Product>>> searchProducts(String query) async {
    try {
      return Result.right(await remoteDataSource.searchProducts(query));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Product>>> getLowStockProducts() async {
    try {
      return Result.right(await remoteDataSource.getLowStockProducts());
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }
}
