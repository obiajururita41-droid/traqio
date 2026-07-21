import 'package:equatable/equatable.dart';
import 'package:traqio/core/enums/payment_method.dart';
import 'package:traqio/features/payments/domain/entities/payment_enums.dart';

/// The unified record of every money movement in Traqio — customer
/// receipts (whether tied to a specific invoice or on-account),
/// supplier payments, refunds, and adjustments all produce one of
/// these. Invoice-linked payments are created by record_invoice_payment
/// (Step 12, extended here); this entity just reads that same table.
class Payment extends Equatable {
  final String id;
  final String businessId;
  final String paymentNumber;
  final PaymentType paymentType;
  final double amount;
  final String currency;
  final PaymentMethod? paymentMethod;
  final String? paymentReference;
  final DateTime paymentDate;
  final String? notes;
  final String? customerId;
  final String? customerName;
  final String? supplierId;
  final String? supplierName;
  final String? invoiceId;
  final String? invoiceNumber;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Payment({
    required this.id,
    required this.businessId,
    required this.paymentNumber,
    required this.paymentType,
    required this.amount,
    this.currency = 'NGN',
    this.paymentMethod,
    this.paymentReference,
    required this.paymentDate,
    this.notes,
    this.customerId,
    this.customerName,
    this.supplierId,
    this.supplierName,
    this.invoiceId,
    this.invoiceNumber,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Who this payment is between, for display purposes.
  String get counterpartyName {
    if (paymentType == PaymentType.supplierPayment) return supplierName ?? 'Unknown supplier';
    return customerName ?? 'Unknown customer';
  }

  @override
  List<Object?> get props => [
        id, businessId, paymentNumber, paymentType, amount, currency,
        paymentMethod, paymentReference, paymentDate, notes, customerId,
        customerName, supplierId, supplierName, invoiceId, invoiceNumber,
        createdBy, createdAt, updatedAt,
      ];
}
