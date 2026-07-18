import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/customers/domain/entities/customer.dart';
import 'package:traqio/features/customers/domain/entities/customer_enums.dart';
import 'package:traqio/features/customers/presentation/providers/customer_form_controller.dart';

class CustomerFormScreen extends ConsumerStatefulWidget {
  final Customer? customer;
  const CustomerFormScreen({super.key, this.customer});

  bool get isEditing => customer != null;

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _address;
  late final TextEditingController _creditLimit;
  late final TextEditingController _notes;
  late CustomerType _customerType;
  late CustomerStatus _status;

  @override
  void initState() {
    super.initState();
    final c = widget.customer;
    _name = TextEditingController(text: c?.name ?? '');
    _phone = TextEditingController(text: c?.phone ?? '');
    _email = TextEditingController(text: c?.email ?? '');
    _address = TextEditingController(text: c?.address ?? '');
    _creditLimit = TextEditingController(text: c?.creditLimit.toString() ?? '0');
    _notes = TextEditingController(text: c?.notes ?? '');
    _customerType = c?.customerType ?? CustomerType.retail;
    _status = c?.status ?? CustomerStatus.active;
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _email, _address, _creditLimit, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final now = DateTime.now();

    final customer = Customer(
      id: widget.customer?.id ?? '',
      businessId: widget.customer?.businessId ?? userId,
      name: _name.text.trim(),
      phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      email: _email.text.trim().isEmpty ? null : _email.text.trim(),
      address: _address.text.trim().isEmpty ? null : _address.text.trim(),
      customerType: _customerType,
      creditLimit: double.tryParse(_creditLimit.text.trim()) ?? 0,
      outstandingBalance: widget.customer?.outstandingBalance ?? 0,
      loyaltyPoints: widget.customer?.loyaltyPoints ?? 0,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      status: _status,
      createdAt: widget.customer?.createdAt ?? now,
      updatedAt: now,
      createdBy: widget.customer?.createdBy ?? userId,
    );

    final controller = ref.read(customerFormControllerProvider.notifier);
    if (widget.isEditing) {
      controller.update(customer);
    } else {
      controller.create(customer);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete customer?'),
        content: Text('This will permanently delete "${widget.customer!.name}".'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(customerFormControllerProvider.notifier).delete(widget.customer!.id);
            },
            child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(customerFormControllerProvider);
    final isLoading = formState is CustomerFormLoading;

    ref.listen<CustomerFormState>(customerFormControllerProvider, (previous, next) {
      if (next is CustomerFormSuccess) {
        Navigator.of(context).pop();
      } else if (next is CustomerFormError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.failure.message)),
        );
      } else if (next is CustomerFormInitial && previous is CustomerFormLoading) {
        Navigator.of(context).pop();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Customer' : 'Add Customer'),
        actions: [
          if (widget.isEditing)
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: isLoading ? null : _confirmDelete),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Customer name *'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone'))),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email'))),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(controller: _address, decoration: const InputDecoration(labelText: 'Address'), maxLines: 2),
              const SizedBox(height: AppSpacing.lg),

              Text('Customer Type', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                children: CustomerType.values.map((type) {
                  return ChoiceChip(
                    label: Text(type.label),
                    selected: _customerType == type,
                    onSelected: (_) => setState(() => _customerType = type),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),

              TextFormField(
                controller: _creditLimit,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Credit limit'),
              ),
              const SizedBox(height: AppSpacing.lg),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active'),
                value: _status == CustomerStatus.active,
                onChanged: (value) {
                  setState(() => _status = value ? CustomerStatus.active : CustomerStatus.inactive);
                },
              ),
              const SizedBox(height: AppSpacing.md),

              TextFormField(controller: _notes, decoration: const InputDecoration(labelText: 'Notes'), maxLines: 2),

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
                      : Text(widget.isEditing ? 'Save Changes' : 'Create Customer'),
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
