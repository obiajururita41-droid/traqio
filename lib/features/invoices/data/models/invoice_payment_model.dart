import 'package:traqio/core/enums/payment_method.dart';
import 'package:traqio/features/invoices/domain/entities/invoice_payment.dart';

class InvoicePaymentModel extends InvoicePayment {
  const InvoicePaymentModel({
    required super.id,
    required super.businessId,
    required super.invoiceId,
    required super.amount,
    super.paymentMethod,
    required super.paymentDate,
    super.notes,
    required super.recordedBy,
    required super.createdAt,
  });

  factory InvoicePaymentModel.fromJson(Map<String, dynamic> json) {
    return InvoicePaymentModel(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      invoiceId: json['invoice_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: PaymentMethodX.fromDb(json['payment_method'] as String?),
      paymentDate: DateTime.parse(json['payment_date'] as String),
      notes: json['notes'] as String?,
      recordedBy: json['recorded_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
