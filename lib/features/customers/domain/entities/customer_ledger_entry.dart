import 'package:equatable/equatable.dart';
import 'package:traqio/features/customers/domain/entities/customer_enums.dart';

/// One row of a customer's ledger — the combined payment history +
/// purchase history requested. Sale/invoice creation posts a debit
/// (increases balance owed); a payment posts a credit (decreases it).
class CustomerLedgerEntry extends Equatable {
  final String id;
  final String businessId;
  final String customerId;

  final LedgerEntryType entryType;
  final LedgerDirection direction;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;

  final String? referenceType;
  final String? referenceId;
  final String? notes;

  final String performedBy;
  final DateTime createdAt;

  const CustomerLedgerEntry({
    required this.id,
    required this.businessId,
    required this.customerId,
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
        id, businessId, customerId, entryType, direction, amount,
        balanceBefore, balanceAfter, referenceType, referenceId, notes,
        performedBy, createdAt,
      ];
}
