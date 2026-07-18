import 'package:traqio/features/customers/domain/entities/customer_enums.dart';
import 'package:traqio/features/customers/domain/entities/customer_ledger_entry.dart';

class LedgerEntryModel extends CustomerLedgerEntry {
  const LedgerEntryModel({
    required super.id,
    required super.businessId,
    required super.customerId,
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

  factory LedgerEntryModel.fromJson(Map<String, dynamic> json) {
    return LedgerEntryModel(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      customerId: json['customer_id'] as String,
      entryType: LedgerEntryTypeX.fromDb(json['entry_type'] as String),
      direction: LedgerDirectionX.fromDb(json['direction'] as String),
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
