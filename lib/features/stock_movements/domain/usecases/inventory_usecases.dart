import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/stock_movements/domain/entities/inventory_movement.dart';
import 'package:traqio/features/stock_movements/domain/entities/movement_type.dart';
import 'package:traqio/features/stock_movements/domain/entities/stock_valuation.dart';
import 'package:traqio/features/stock_movements/domain/repositories/inventory_repository.dart';

class RecordMovementUseCase {
  final InventoryRepository repository;
  const RecordMovementUseCase(this.repository);

  Future<Result<InventoryMovement>> call({
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
  }) {
    return repository.recordMovement(
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
  }
}

class GetMovementHistoryUseCase {
  final InventoryRepository repository;
  const GetMovementHistoryUseCase(this.repository);
  Future<Result<List<InventoryMovement>>> call({String? productId}) =>
      repository.getMovementHistory(productId: productId);
}

class GetMovementsByReferenceUseCase {
  final InventoryRepository repository;
  const GetMovementsByReferenceUseCase(this.repository);
  Future<Result<List<InventoryMovement>>> call(
          ReferenceType referenceType, String referenceId) =>
      repository.getMovementsByReference(referenceType, referenceId);
}

class GetStockValuationUseCase {
  final InventoryRepository repository;
  const GetStockValuationUseCase(this.repository);
  Future<Result<StockValuation>> call() => repository.getStockValuation();
}
