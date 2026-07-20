import 'package:equatable/equatable.dart';
import 'package:traqio/features/invoices/domain/entities/invoice_enums.dart';
import 'package:traqio/features/invoices/domain/entities/invoice_item.dart';

class Invoice extends Equatable {
  final String id;
  final String businessId;
  final String salesOrderId;
  final String? salesOrderNumber;
  final String customerId;
  final String? customerName;
  final String invoiceNumber;
  final InvoiceStatus status;
  final DateTime issueDate;
  final DateTime? dueDate;
  final String? notes;
  final double subtotal;
  final double taxAmount;
  final double totalAmount;
  final double paidAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final List<InvoiceItem> items;

  const Invoice({
    required this.id,
    required this.businessId,
    required this.salesOrderId,
    this.salesOrderNumber,
    required this.customerId,
    this.customerName,
    required this.invoiceNumber,
    this.status = InvoiceStatus.draft,
    required this.issueDate,
    this.dueDate,
    this.notes,
    this.subtotal = 0,
    this.taxAmount = 0,
    this.totalAmount = 0,
    this.paidAmount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.items = const [],
  });

  double get balanceDue => totalAmount - paidAmount;

  /// Effective status accounting for overdue — the DB stores a fixed
  /// status, but "overdue" is really a time-based derived condition on
  /// top of sent/partially_paid, computed here rather than requiring a
  /// background job to keep the stored status in sync.
  InvoiceStatus get effectiveStatus {
    final isUnsettled = status == InvoiceStatus.sent || status == InvoiceStatus.partiallyPaid;
    if (isUnsettled && dueDate != null && dueDate!.isBefore(DateTime.now())) {
      return InvoiceStatus.overdue;
    }
    return status;
  }

  bool get canEdit => status == InvoiceStatus.draft;
  bool get canCancel => status == InvoiceStatus.draft || status == InvoiceStatus.sent;
  bool get canRecordPayment =>
      status == InvoiceStatus.sent || status == InvoiceStatus.partiallyPaid;

  @override
  List<Object?> get props => [
        id, businessId, salesOrderId, salesOrderNumber, customerId, customerName,
        invoiceNumber, status, issueDate, dueDate, notes, subtotal, taxAmount,
        totalAmount, paidAmount, createdAt, updatedAt, createdBy, items,
      ];
}
