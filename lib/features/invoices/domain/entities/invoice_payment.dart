import 'package:equatable/equatable.dart';
import 'package:traqio/features/invoices/domain/entities/invoice_enums.dart';

class InvoicePayment extends Equatable {
  final String id;
  final String businessId;
  final String invoiceId;
  final double amount;
  final PaymentMethod? paymentMethod;
  final DateTime paymentDate;
  final String? notes;
  final String recordedBy;
  final DateTime createdAt;

  const InvoicePayment({
    required this.id,
    required this.businessId,
    required this.invoiceId,
    required this.amount,
    this.paymentMethod,
    required this.paymentDate,
    this.notes,
    required this.recordedBy,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id, businessId, invoiceId, amount, paymentMethod, paymentDate,
        notes, recordedBy, createdAt,
      ];
}
