import 'package:traqio/core/enums/payment_method.dart';
import 'package:traqio/features/payments/domain/entities/payment.dart';
import 'package:traqio/features/payments/domain/entities/payment_enums.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.businessId,
    required super.paymentNumber,
    required super.paymentType,
    required super.amount,
    super.currency,
    super.paymentMethod,
    super.paymentReference,
    required super.paymentDate,
    super.notes,
    super.customerId,
    super.customerName,
    super.supplierId,
    super.supplierName,
    super.invoiceId,
    super.invoiceNumber,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    String? customerName;
    final customerJoin = json['customers'];
    if (customerJoin is Map<String, dynamic>) {
      customerName = customerJoin['name'] as String?;
    }

    String? supplierName;
    final supplierJoin = json['suppliers'];
    if (supplierJoin is Map<String, dynamic>) {
      supplierName = supplierJoin['name'] as String?;
    }

    String? invoiceNumber;
    final invoiceJoin = json['invoices'];
    if (invoiceJoin is Map<String, dynamic>) {
      invoiceNumber = invoiceJoin['invoice_number'] as String?;
    }

    return PaymentModel(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      paymentNumber: json['payment_number'] as String,
      paymentType: PaymentTypeX.fromDb(json['payment_type'] as String),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'NGN',
      paymentMethod: PaymentMethodX.fromDb(json['payment_method'] as String?),
      paymentReference: json['payment_reference'] as String?,
      paymentDate: DateTime.parse(json['payment_date'] as String),
      notes: json['notes'] as String?,
      customerId: json['customer_id'] as String?,
      customerName: customerName,
      supplierId: json['supplier_id'] as String?,
      supplierName: supplierName,
      invoiceId: json['invoice_id'] as String?,
      invoiceNumber: invoiceNumber,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
