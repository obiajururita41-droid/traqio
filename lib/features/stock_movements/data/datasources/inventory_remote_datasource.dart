import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:traqio/core/errors/exceptions.dart';
import 'package:traqio/features/stock_movements/data/models/inventory_movement_model.dart';
import 'package:traqio/features/stock_movements/domain/entities/movement_type.dart';

class InventoryRemoteDataSource {
  final SupabaseClient client;
  final String businessId;
  const InventoryRemoteDataSource(this.client, this.businessId);

  static const _movementsTable = 'inventory_movements';
  static const _productsTable = 'products';

  /// Calls the atomic RPC — never inserts into inventory_movements
  /// directly. This guarantees the movement log and the product's
  /// current_stock can never drift apart, even under concurrent edits.
  Future<InventoryMovementModel> recordMovement({
    required String productId,
    String? warehouseId,
    required MovementType movementType,
    required MovementDirection direction,
    required double quantity,
    double? unitCost,
    AdjustmentReason? reasonCode,
    ReferenceType? referenceType,
    String? referenceId,
    String? batchNumber,
    DateTime? expiryDate,
    String? notes,
  }) async {
    try {
      final row = await client.rpc('create_inventory_movement', params: {
        'p_business_id': businessId,
        'p_product_id': productId,
        'p_warehouse_id': warehouseId,
        'p_movement_type': movementType.dbValue,
        'p_direction': direction.dbValue,
        'p_quantity': quantity,
        'p_unit_cost': unitCost,
        'p_reason_code': reasonCode?.dbValue,
        'p_reference_type': referenceType?.dbValue,
        'p_reference_id': referenceId,
        'p_batch_number': batchNumber,
        'p_expiry_date': expiryDate?.toIso8601String(),
        'p_notes': notes,
      });
      return InventoryMovementModel.fromJson(row as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<List<InventoryMovementModel>> getMovementHistory({String? productId}) async {
    try {
      var query = client
          .from(_movementsTable)
          .select()
          .eq('business_id', businessId);
      if (productId != null) {
        query = query.eq('product_id', productId);
      }
      final rows = await query.order('created_at', ascending: false);
      return (rows as List)
          .map((row) => InventoryMovementModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<List<InventoryMovementModel>> getMovementsByReference(
      ReferenceType referenceType, String referenceId) async {
    try {
      final rows = await client
          .from(_movementsTable)
          .select()
          .eq('business_id', businessId)
          .eq('reference_type', referenceType.dbValue)
          .eq('reference_id', referenceId)
          .order('created_at', ascending: false);
      return (rows as List)
          .map((row) => InventoryMovementModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Aggregates directly from Products — no separate valuation table
  /// needed at this stage. Swappable for a FIFO-layer calculation
  /// later without changing the domain contract.
  Future<Map<String, dynamic>> getStockValuationRaw() async {
    try {
      final rows = await client
          .from(_productsTable)
          .select('current_stock, cost_price, minimum_stock, reorder_level')
          .eq('business_id', businessId);

      double totalValue = 0;
      int lowStockCount = 0;
      int outOfStockCount = 0;
      final list = rows as List;

      for (final row in list) {
        final currentStock = (row['current_stock'] as num).toDouble();
        final costPrice = (row['cost_price'] as num).toDouble();
        final minimumStock = (row['minimum_stock'] as num).toDouble();

        totalValue += currentStock * costPrice;
        if (currentStock <= 0) {
          outOfStockCount++;
        } else if (currentStock <= minimumStock) {
          lowStockCount++;
        }
      }

      return {
        'total_stock_value': totalValue,
        'low_stock_count': lowStockCount,
        'out_of_stock_count': outOfStockCount,
        'total_product_count': list.length,
      };
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
