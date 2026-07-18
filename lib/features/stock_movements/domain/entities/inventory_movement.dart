import 'package:equatable/equatable.dart';
import 'package:traqio/features/stock_movements/domain/entities/movement_type.dart';

/// One row of the inventory audit trail. Every stock change of any
/// kind — sale, purchase receipt, adjustment, transfer, return,
/// damage, or expiry — is represented by one InventoryMovement,
/// created via the atomic create_inventory_movement RPC so that the
/// movement log and Product.currentStock never drift out of sync.
class InventoryMovement extends Equatable {
  final String id;
  final String businessId;
  final String productId;
  final String? warehouseId;

  final MovementType movementType;
  final MovementDirection direction;
  final double quantity;
  final double quantityBefore;
  final double quantityAfter;
  final double? unitCost;

  final AdjustmentReason? reasonCode;
  final ReferenceType? referenceType;
  final String? referenceId;

  final String? batchNumber;
  final DateTime? expiryDate;
  final String? notes;

  final String performedBy;
  final DateTime createdAt;

  const InventoryMovement({
    required this.id,
    required this.businessId,
    required this.productId,
    this.warehouseId,
    required this.movementType,
    required this.direction,
    required this.quantity,
    required this.quantityBefore,
    required this.quantityAfter,
    this.unitCost,
    this.reasonCode,
    this.referenceType,
    this.referenceId,
    this.batchNumber,
    this.expiryDate,
    this.notes,
    required this.performedBy,
    required this.createdAt,
  });

  /// Valuation contribution of this single movement — the building
  /// block for a future FIFO costing engine (which would consume
  /// stock-in movements in creation order rather than using a single
  /// weighted-average cost).
  double? get movementValue => unitCost == null ? null : unitCost! * quantity;

  @override
  List<Object?> get props => [
        id, businessId, productId, warehouseId, movementType, direction,
        quantity, quantityBefore, quantityAfter, unitCost, reasonCode,
        referenceType, referenceId, batchNumber, expiryDate, notes,
        performedBy, createdAt,
      ];
}
