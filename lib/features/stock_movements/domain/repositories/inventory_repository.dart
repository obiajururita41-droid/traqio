import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/stock_movements/domain/entities/inventory_movement.dart';
import 'package:traqio/features/stock_movements/domain/entities/movement_type.dart';
import 'package:traqio/features/stock_movements/domain/entities/stock_valuation.dart';

abstract class InventoryRepository {
  /// Creates a movement AND updates the product's stock atomically
  /// via the create_inventory_movement RPC. This is the single entry
  /// point every module (Sales, Purchases, POS, Returns) should use
  /// to change stock — never update Product.currentStock directly.
  Future<Result<InventoryMovement>> recordMovement({
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
  });

  Future<Result<List<InventoryMovement>>> getMovementHistory({String? productId});
  Future<Result<List<InventoryMovement>>> getMovementsByReference(
      ReferenceType referenceType, String referenceId);
  Future<Result<StockValuation>> getStockValuation();
}
