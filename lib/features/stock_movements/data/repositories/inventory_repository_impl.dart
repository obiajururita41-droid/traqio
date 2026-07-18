import 'package:traqio/core/errors/failures.dart';
import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/stock_movements/data/datasources/inventory_remote_datasource.dart';
import 'package:traqio/features/stock_movements/domain/entities/inventory_movement.dart';
import 'package:traqio/features/stock_movements/domain/entities/movement_type.dart';
import 'package:traqio/features/stock_movements/domain/entities/stock_valuation.dart';
import 'package:traqio/features/stock_movements/domain/repositories/inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource remoteDataSource;
  const InventoryRepositoryImpl(this.remoteDataSource);

  @override
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
  }) async {
    try {
      final movement = await remoteDataSource.recordMovement(
        productId: productId,
        warehouseId: warehouseId,
        movementType: movementType,
        direction: direction,
        quantity: quantity,
        unitCost: unitCost,
        reasonCode: reasonCode,
        referenceType: referenceType,
        referenceId: referenceId,
        batchNumber: batchNumber,
        expiryDate: expiryDate,
        notes: notes,
      );
      return Result.right(movement);
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<InventoryMovement>>> getMovementHistory({String? productId}) async {
    try {
      return Result.right(await remoteDataSource.getMovementHistory(productId: productId));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<InventoryMovement>>> getMovementsByReference(
      ReferenceType referenceType, String referenceId) async {
    try {
      return Result.right(
          await remoteDataSource.getMovementsByReference(referenceType, referenceId));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<StockValuation>> getStockValuation() async {
    try {
      final raw = await remoteDataSource.getStockValuationRaw();
      return Result.right(StockValuation(
        totalStockValue: (raw['total_stock_value'] as num).toDouble(),
        lowStockCount: raw['low_stock_count'] as int,
        outOfStockCount: raw['out_of_stock_count'] as int,
        totalProductCount: raw['total_product_count'] as int,
      ));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }
}
