import 'package:traqio/features/stock_movements/domain/entities/inventory_movement.dart';
import 'package:traqio/features/stock_movements/domain/entities/movement_type.dart';

class InventoryMovementModel extends InventoryMovement {
  const InventoryMovementModel({
    required super.id,
    required super.businessId,
    required super.productId,
    super.warehouseId,
    required super.movementType,
    required super.direction,
    required super.quantity,
    required super.quantityBefore,
    required super.quantityAfter,
    super.unitCost,
    super.reasonCode,
    super.referenceType,
    super.referenceId,
    super.batchNumber,
    super.expiryDate,
    super.notes,
    required super.performedBy,
    required super.createdAt,
  });

  factory InventoryMovementModel.fromJson(Map<String, dynamic> json) {
    double? asDouble(dynamic v) => v == null ? null : (v as num).toDouble();
    DateTime? asDate(dynamic v) => v == null ? null : DateTime.parse(v as String);

    return InventoryMovementModel(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      productId: json['product_id'] as String,
      warehouseId: json['warehouse_id'] as String?,
      movementType: MovementTypeX.fromDb(json['movement_type'] as String),
      direction: MovementDirectionX.fromDb(json['direction'] as String),
      quantity: (json['quantity'] as num).toDouble(),
      quantityBefore: (json['quantity_before'] as num).toDouble(),
      quantityAfter: (json['quantity_after'] as num).toDouble(),
      unitCost: asDouble(json['unit_cost']),
      reasonCode: AdjustmentReasonX.fromDb(json['reason_code'] as String?),
      referenceType: ReferenceTypeX.fromDb(json['reference_type'] as String?),
      referenceId: json['reference_id'] as String?,
      batchNumber: json['batch_number'] as String?,
      expiryDate: asDate(json['expiry_date']),
      notes: json['notes'] as String?,
      performedBy: json['performed_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
