import 'package:traqio/features/suppliers/domain/entities/supplier_enums.dart';
import 'package:traqio/features/suppliers/domain/entities/supplier_ledger_entry.dart';

class SupplierLedgerEntryModel extends SupplierLedgerEntry {
  const SupplierLedgerEntryModel({
    required super.id,
    required super.businessId,
    required super.supplierId,
    required super.entryType,
    required super.direction,
    required super.amount,
    required super.balanceBefore,
    required super.balanceAfter,
    super.referenceType,
    super.referenceId,
    super.notes,
    required super.performedBy,
    required super.createdAt,
  });

  factory SupplierLedgerEntryModel.fromJson(Map<String, dynamic> json) {
    return SupplierLedgerEntryModel(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      supplierId: json['supplier_id'] as String,
      entryType: SupplierLedgerEntryTypeX.fromDb(json['entry_type'] as String),
      direction: SupplierLedgerDirectionX.fromDb(json['direction'] as String),
      amount: (json['amount'] as num).toDouble(),
      balanceBefore: (json['balance_before'] as num).toDouble(),
      balanceAfter: (json['balance_after'] as num).toDouble(),
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id'] as String?,
      notes: json['notes'] as String?,
      performedBy: json['performed_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
