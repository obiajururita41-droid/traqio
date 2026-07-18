import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/stock_movements/domain/entities/inventory_movement.dart';
import 'package:traqio/features/stock_movements/domain/entities/movement_type.dart';

/// Reusable movement row. Used in the global Inventory History screen
/// and (later) embedded on Product detail, Sales Order detail, and
/// Purchase Order detail screens via the same referenceType linkage.
class MovementTile extends StatelessWidget {
  final InventoryMovement movement;
  final String? productName;

  const MovementTile({super.key, required this.movement, this.productName});

  IconData get _icon {
    switch (movement.movementType) {
      case MovementType.stockIn: return Icons.arrow_downward_rounded;
      case MovementType.stockOut: return Icons.arrow_upward_rounded;
      case MovementType.adjustment: return Icons.tune_rounded;
      case MovementType.transfer: return Icons.swap_horiz_rounded;
      case MovementType.returnMovement: return Icons.undo_rounded;
      case MovementType.damaged: return Icons.report_problem_outlined;
      case MovementType.expired: return Icons.event_busy_rounded;
    }
  }

  Color _color(BuildContext context) {
    final isIncrease = movement.direction == MovementDirection.increase;
    if (movement.movementType == MovementType.damaged ||
        movement.movementType == MovementType.expired) {
      return Theme.of(context).colorScheme.error;
    }
    return isIncrease ? Colors.green : Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _color(context);
    final sign = movement.direction == MovementDirection.increase ? '+' : '-';
    final dateFormat = DateFormat('d MMM, h:mm a');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(_icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName ?? movement.movementType.label,
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    movement.movementType.label,
                    if (movement.reasonCode != null) movement.reasonCode!.label,
                    dateFormat.format(movement.createdAt),
                  ].join(' · '),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$sign${movement.quantity.toStringAsFixed(0)}',
            style: theme.textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
