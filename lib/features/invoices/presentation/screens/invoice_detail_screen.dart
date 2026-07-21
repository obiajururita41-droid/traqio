import 'package:flutter/material.dart';
import 'package:traqio/core/enums/payment_method.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/invoices/domain/entities/invoice.dart';
import 'package:traqio/features/invoices/domain/entities/invoice_enums.dart';
import 'package:traqio/features/invoices/domain/entities/invoice_item.dart';
import 'package:traqio/features/invoices/presentation/providers/invoice_form_controller.dart';
import 'package:traqio/features/invoices/presentation/providers/invoice_payment_controller.dart';
import 'package:traqio/features/invoices/presentation/providers/invoice_providers.dart';
import 'package:traqio/features/invoices/presentation/widgets/invoice_status_badge.dart';

class InvoiceDetailScreen extends ConsumerWidget {
  final String invoiceId;
  const InvoiceDetailScreen({super.key, required this.invoiceId});

  void _confirmCancel(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel invoice?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('No')),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(invoiceFormControllerProvider.notifier).cancel(id);
            },
            child: Text('Yes, cancel', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void _openPaymentSheet(BuildContext context, Invoice invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _RecordPaymentSheet(invoice: invoice),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final invoiceAsync = ref.watch(invoiceDetailProvider(invoiceId));
    final formState = ref.watch(invoiceFormControllerProvider);
    final isLoading = formState is InvoiceFormLoading;
    final currency = NumberFormat.currency(symbol: '₦', decimalDigits: 0);
    final dateFormat = DateFormat('d MMM y');

    ref.listen<InvoiceFormState>(invoiceFormControllerProvider, (previous, next) {
      if (next is InvoiceFormError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.failure.message)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: invoiceAsync.whenOrNull(data: (inv) => Text(inv.invoiceNumber)) ?? const Text('Invoice'),
      ),
      body: SafeArea(
        child: invoiceAsync.when(
          data: (invoice) => ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InvoiceStatusBadge(status: invoice.effectiveStatus),
                  Text('From ${invoice.salesOrderNumber ?? 'SO'}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      )),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              _InfoRow(label: 'Customer', value: invoice.customerName ?? '—'),
              _InfoRow(label: 'Issue date', value: dateFormat.format(invoice.issueDate)),
              if (invoice.dueDate != null)
                _InfoRow(label: 'Due date', value: dateFormat.format(invoice.dueDate!)),
              if (invoice.notes != null && invoice.notes!.isNotEmpty)
                _InfoRow(label: 'Notes', value: invoice.notes!),

              const SizedBox(height: AppSpacing.xl),
              Text('Items', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              for (final item in invoice.items) _ItemRow(item: item, currency: currency),

              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Column(
                  children: [
                    _TotalRow(label: 'Subtotal', value: currency.format(invoice.subtotal)),
                    _TotalRow(label: 'Tax', value: currency.format(invoice.taxAmount)),
                    const Divider(),
                    _TotalRow(label: 'Total', value: currency.format(invoice.totalAmount), isBold: true),
                    _TotalRow(label: 'Paid', value: currency.format(invoice.paidAmount)),
                    _TotalRow(
                      label: 'Balance Due',
                      value: currency.format(invoice.balanceDue),
                      isBold: true,
                      color: invoice.balanceDue > 0 ? theme.colorScheme.error : Colors.green,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              if (invoice.status == InvoiceStatus.draft) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : () {
                      ref.read(invoiceFormControllerProvider.notifier).markAsSent(invoice.id);
                    },
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Mark as Sent'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              if (invoice.canRecordPayment) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openPaymentSheet(context, invoice),
                    icon: const Icon(Icons.payments_outlined),
                    label: const Text('Record Payment'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              if (invoice.canCancel)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : () => _confirmCancel(context, ref, invoice.id),
                    icon: Icon(Icons.cancel_outlined, color: theme.colorScheme.error),
                    label: Text('Cancel Invoice', style: TextStyle(color: theme.colorScheme.error)),
                  ),
                ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Could not load invoice: $e')),
        ),
      ),
    );
  }
}

class _RecordPaymentSheet extends ConsumerStatefulWidget {
  final Invoice invoice;
  const _RecordPaymentSheet({required this.invoice});

  @override
  ConsumerState<_RecordPaymentSheet> createState() => _RecordPaymentSheetState();
}

class _RecordPaymentSheetState extends ConsumerState<_RecordPaymentSheet> {
  late final TextEditingController _amountController;
  PaymentMethod? _method;
  DateTime _paymentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.invoice.balanceDue.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid payment amount')),
      );
      return;
    }
    if (amount > widget.invoice.balanceDue) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Amount exceeds balance due of ${widget.invoice.balanceDue}')),
      );
      return;
    }

    ref.read(invoicePaymentControllerProvider.notifier).recordPayment(
          invoiceId: widget.invoice.id,
          customerId: widget.invoice.customerId,
          amount: amount,
          paymentMethod: _method,
          paymentDate: _paymentDate,
          notes: null,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paymentState = ref.watch(invoicePaymentControllerProvider);
    final isLoading = paymentState is InvoicePaymentLoading;
    final currency = NumberFormat.currency(symbol: '₦', decimalDigits: 0);

    ref.listen<InvoicePaymentState>(invoicePaymentControllerProvider, (previous, next) {
      if (next is InvoicePaymentSuccess) {
        Navigator.of(context).pop();
      } else if (next is InvoicePaymentError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.failure.message)));
      }
    });

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.xl, right: AppSpacing.xl, top: AppSpacing.xl,
        bottom: AppSpacing.xl + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Record Payment', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Balance due: ${currency.format(widget.invoice.balanceDue)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Amount *'),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<PaymentMethod>(
            initialValue: _method,
            decoration: const InputDecoration(labelText: 'Payment method (optional)'),
            items: PaymentMethod.values
                .map((m) => DropdownMenuItem(value: m, child: Text(m.label)))
                .toList(),
            onChanged: (m) => setState(() => _method = m),
          ),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context, initialDate: _paymentDate,
                firstDate: DateTime(2020), lastDate: DateTime(2100),
              );
              if (picked != null) setState(() => _paymentDate = picked);
            },
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Payment date'),
              child: Text(DateFormat('d MMM y').format(_paymentDate)),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: isLoading ? null : _submit,
            child: isLoading
                ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Confirm Payment'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                )),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final InvoiceItem item;
  final NumberFormat currency;
  const _ItemRow({required this.item, required this.currency});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.description ?? 'Product', style: theme.textTheme.bodyMedium),
                Text(
                  '${item.quantity.toStringAsFixed(0)} × ${currency.format(item.unitPrice)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(currency.format(item.lineTotal), style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? color;
  const _TotalRow({required this.label, required this.value, this.isBold = false, this.color});

  @override
  Widget build(BuildContext context) {
    final baseStyle = isBold
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium;
    final style = color != null ? baseStyle?.copyWith(color: color) : baseStyle;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }
}
