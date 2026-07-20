import 'package:equatable/equatable.dart';

class InvoiceItem extends Equatable {
  final String id;
  final String invoiceId;
  final String productId;
  final String? description;
  final double quantity;
  final double unitPrice;
  final double taxRate;
  final double lineTotal;

  const InvoiceItem({
    required this.id,
    required this.invoiceId,
    required this.productId,
    this.description,
    required this.quantity,
    required this.unitPrice,
    this.taxRate = 0,
    this.lineTotal = 0,
  });

  @override
  List<Object?> get props =>
      [id, invoiceId, productId, description, quantity, unitPrice, taxRate, lineTotal];
}
