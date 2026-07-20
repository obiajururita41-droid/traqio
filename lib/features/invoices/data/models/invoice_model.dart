import 'package:traqio/features/invoices/data/models/invoice_item_model.dart';
import 'package:traqio/features/invoices/domain/entities/invoice.dart';
import 'package:traqio/features/invoices/domain/entities/invoice_enums.dart';

class InvoiceModel extends Invoice {
  const InvoiceModel({
    required super.id,
    required super.businessId,
    required super.salesOrderId,
    super.salesOrderNumber,
    required super.customerId,
    super.customerName,
    required super.invoiceNumber,
    super.status,
    required super.issueDate,
    super.dueDate,
    super.notes,
    super.subtotal,
    super.taxAmount,
    super.totalAmount,
    super.paidAmount,
    required super.createdAt,
    required super.updatedAt,
    super.createdBy,
    super.items,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    String? customerName;
    final customerJoin = json['customers'];
    if (customerJoin is Map<String, dynamic>) {
      customerName = customerJoin['name'] as String?;
    }

    String? soNumber;
    final soJoin = json['sales_orders'];
    if (soJoin is Map<String, dynamic>) {
      soNumber = soJoin['so_number'] as String?;
    }

    final itemsJson = json['invoice_items'] as List?;
    final items = itemsJson
            ?.map((row) => InvoiceItemModel.fromJson(row as Map<String, dynamic>))
            .toList() ??
        const <InvoiceItemModel>[];

    return InvoiceModel(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      salesOrderId: json['sales_order_id'] as String,
      salesOrderNumber: soNumber,
      customerId: json['customer_id'] as String,
      customerName: customerName,
      invoiceNumber: json['invoice_number'] as String,
      status: InvoiceStatusX.fromDb(json['status'] as String? ?? 'draft'),
      issueDate: DateTime.parse(json['issue_date'] as String),
      dueDate: json['due_date'] == null ? null : DateTime.parse(json['due_date'] as String),
      notes: json['notes'] as String?,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      createdBy: json['created_by'] as String?,
      items: items,
    );
  }
}
