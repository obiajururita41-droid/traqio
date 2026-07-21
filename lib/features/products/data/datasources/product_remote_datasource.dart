import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:traqio/core/errors/exceptions.dart';
import 'package:traqio/features/products/data/models/product_model.dart';
import 'package:traqio/features/products/domain/entities/product.dart';

class ProductRemoteDataSource {
  final SupabaseClient client;
  final String businessId;
  const ProductRemoteDataSource(this.client, this.businessId);

  static const _table = 'products';

  Future<List<ProductModel>> getProducts() async {
    try {
      final rows = await client
          .from(_table)
          .select()
          .eq('business_id', businessId)
          .order('created_at', ascending: false);
      return (rows as List)
          .map((row) => ProductModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<ProductModel> getProductById(String id) async {
    try {
      final row = await client
          .from(_table)
          .select()
          .eq('id', id)
          .eq('business_id', businessId)
          .single();
      return ProductModel.fromJson(row);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<ProductModel> createProduct(Product product) async {
    try {
      final payload = ProductModel.fromEntity(product).toJson()
        ..remove('id')
        ..['business_id'] = businessId;
      final row =
          await client.from(_table).insert(payload).select().single();
      return ProductModel.fromJson(row);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<ProductModel> updateProduct(Product product) async {
    try {
      final payload = ProductModel.fromEntity(product).toJson()
        ..['updated_at'] = DateTime.now().toIso8601String();
      final row = await client
          .from(_table)
          .update(payload)
          .eq('id', product.id)
          .eq('business_id', businessId)
          .select()
          .single();
      return ProductModel.fromJson(row);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await client
          .from(_table)
          .delete()
          .eq('id', id)
          .eq('business_id', businessId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final rows = await client
          .from(_table)
          .select()
          .eq('business_id', businessId)
          .or('name.ilike.%$query%,sku.ilike.%$query%,barcode.ilike.%$query%');
      return (rows as List)
          .map((row) => ProductModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<List<ProductModel>> getLowStockProducts() async {
    try {
      final rows = await client
          .from(_table)
          .select()
          .eq('business_id', businessId);
      final all = (rows as List)
          .map((row) => ProductModel.fromJson(row as Map<String, dynamic>))
          .toList();
      return all.where((p) => p.isLowStock).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
