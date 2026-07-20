import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/invoices/presentation/providers/invoice_form_controller.dart';
import 'package:traqio/features/invoices/presentation/screens/invoice_detail_screen.dart';
import 'package:traqio/features/sales_orders/domain/entities/sales_order.dart';

class GenerateInvoiceScreen extends ConsumerStatefulWidget {
  final SalesOrder salesOrder;
  const GenerateInvoiceScreen({super.key, required this.salesOrder});

  @override
  ConsumerState<GenerateInvoiceScreen> createState() => _GenerateInvoiceScreenState();
}

class _GenerateInvoiceScreenState extends ConsumerState<GenerateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _invoiceNumberController;
  late final TextEditingController _notesController;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _invoiceNumberController = TextEditingController(
      text: 'INV-${DateTime.now().millisecondsSinceEpoch % 100000}',
    );
    _notesController = TextEditingController();
    _dueDate = DateTime.now().add(const Duration(days: 14));
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref.read(invoiceFormControllerProvider.notifier).generateFromSalesOrder(
          salesOrderId: widget.salesOrder.id,
          invoiceNumber: _invoiceNumberController.text.trim(),
          dueDate: _dueDate,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(invoiceFormControllerProvider);
    final isLoading = formState is InvoiceFormLoading;

    ref.listen<InvoiceFormState>(invoiceFormControllerProvider, (previous, next) {
      if (next is InvoiceFormSuccess) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => InvoiceDetailScreen(invoiceId: next.invoice.id)),
        );
      } else if (next is InvoiceFormError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.failure.message)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Generate Invoice')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              Text(
                'From Sales Order: ${widget.salesOrder.soNumber}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
              ),
              const SizedBox(height: AppSpacing.xl),
              TextFormField(
                controller: _invoiceNumberController,
                decoration: const InputDecoration(labelText: 'Invoice Number *'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 14)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _dueDate = picked);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Due date'),
                  child: Text(_dueDate == null ? 'Not set' : DateFormat('d MMM y').format(_dueDate!)),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Generate Invoice'),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
