import 'package:equatable/equatable.dart';
import 'package:traqio/features/suppliers/domain/entities/supplier_enums.dart';

class SupplierLedgerEntry extends Equatable {
  final String id;
  final String businessId;
  final String supplierId;

  final SupplierLedgerEntryType entryType;
  final SupplierLedgerDirection direction;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;

  final String? referenceType;
  final String? referenceId;
  final String? notes;

  final String performedBy;
  final DateTime createdAt;

  const SupplierLedgerEntry({
    required this.id,
    required this.businessId,
    required this.supplierId,
    required this.entryType,
    required this.direction,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    this.referenceType,
    this.referenceId,
    this.notes,
    required this.performedBy,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id, businessId, supplierId, entryType, direction, amount,
        balanceBefore, balanceAfter, referenceType, referenceId, notes,
        performedBy, createdAt,
      ];
}
