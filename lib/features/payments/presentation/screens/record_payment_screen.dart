import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:traqio/core/enums/payment_method.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/customers/domain/entities/customer.dart';
import 'package:traqio/features/customers/presentation/providers/customer_providers.dart';
import 'package:traqio/features/payments/presentation/providers/payment_form_controller.dart';
import 'package:traqio/features/suppliers/domain/entities/supplier.dart';
import 'package:traqio/features/suppliers/presentation/providers/supplier_providers.dart';

enum _PartyType { customer, supplier }

class RecordPaymentScreen extends ConsumerStatefulWidget {
  const RecordPaymentScreen({super.key});

  @override
  ConsumerState<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends ConsumerState<RecordPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();

  _PartyType _partyType = _PartyType.customer;
  Customer? _selectedCustomer;
  Supplier? _selectedSupplier;
  PaymentMethod? _method;
  DateTime _paymentDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_partyType == _PartyType.customer && _selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a customer first')),
      );
      return;
    }
    if (_partyType == _PartyType.supplier && _selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a supplier first')),
      );
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final controller = ref.read(paymentFormControllerProvider.notifier);

    if (_partyType == _PartyType.customer) {
      controller.recordCustomerPayment(
        customerId: _selectedCustomer!.id,
        amount: amount,
        paymentMethod: _method,
        paymentReference: _referenceController.text.trim().isEmpty
            ? null
            : _referenceController.text.trim(),
        paymentDate: _paymentDate,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );
    } else {
      controller.recordSupplierPayment(
        supplierId: _selectedSupplier!.id,
        amount: amount,
        paymentMethod: _method,
        paymentReference: _referenceController.text.trim().isEmpty
            ? null
            : _referenceController.text.trim(),
        paymentDate: _paymentDate,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(paymentFormControllerProvider);
    final isLoading = formState is PaymentFormLoading;
    final customersAsync = ref.watch(customersProvider);
    final suppliersAsync = ref.watch(suppliersProvider);

    ref.listen<PaymentFormState>(paymentFormControllerProvider, (previous, next) {
      if (next is PaymentFormSuccess) {
        Navigator.of(context).pop();
      } else if (next is PaymentFormError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.failure.message)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Record Payment')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              SegmentedButton<_PartyType>(
                segments: const [
                  ButtonSegment(value: _PartyType.customer, label: Text('From Customer')),
                  ButtonSegment(value: _PartyType.supplier, label: Text('To Supplier')),
                ],
                selected: {_partyType},
                onSelectionChanged: (selection) {
                  setState(() => _partyType = selection.first);
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              if (_partyType == _PartyType.customer)
                customersAsync.when(
                  data: (customers) => DropdownButtonFormField<Customer>(
                    initialValue: _selectedCustomer,
                    decoration: const InputDecoration(labelText: 'Customer *'),
                    items: customers
                        .map((c) => DropdownMenuItem(value: c, child: Text(c.name, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (c) => setState(() => _selectedCustomer = c),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, st) => Text('Could not load customers: $e'),
                )
              else
                suppliersAsync.when(
                  data: (suppliers) => DropdownButtonFormField<Supplier>(
                    initialValue: _selectedSupplier,
                    decoration: const InputDecoration(labelText: 'Supplier *'),
                    items: suppliers
                        .map((s) => DropdownMenuItem(value: s, child: Text(s.name, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (s) => setState(() => _selectedSupplier = s),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, st) => Text('Could not load suppliers: $e'),
                ),
              const SizedBox(height: AppSpacing.md),

              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount *'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
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

              TextFormField(
                controller: _referenceController,
                decoration: const InputDecoration(labelText: 'Reference (optional)'),
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
                      : const Text('Record Payment'),
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
