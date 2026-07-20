import 'package:traqio/features/invoices/domain/entities/invoice_item.dart';

class InvoiceItemModel extends InvoiceItem {
  const InvoiceItemModel({
    required super.id,
    required super.invoiceId,
    required super.productId,
    super.description,
    required super.quantity,
    required super.unitPrice,
    super.taxRate,
    super.lineTotal,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: json['id'] as String,
      invoiceId: json['invoice_id'] as String,
      productId: json['product_id'] as String,
      description: json['description'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      taxRate: (json['tax_rate'] as num?)?.toDouble() ?? 0,
      lineTotal: (json['line_total'] as num?)?.toDouble() ?? 0,
    );
  }
}
