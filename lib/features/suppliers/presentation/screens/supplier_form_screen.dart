import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/suppliers/domain/entities/supplier.dart';
import 'package:traqio/features/suppliers/domain/entities/supplier_enums.dart';
import 'package:traqio/features/suppliers/presentation/providers/supplier_form_controller.dart';

class SupplierFormScreen extends ConsumerStatefulWidget {
  final Supplier? supplier;
  const SupplierFormScreen({super.key, this.supplier});

  bool get isEditing => supplier != null;

  @override
  ConsumerState<SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends ConsumerState<SupplierFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _contactPerson;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _address;
  late final TextEditingController _paymentTerms;
  late final TextEditingController _notes;
  late SupplierType _supplierType;
  late SupplierStatus _status;

  @override
  void initState() {
    super.initState();
    final s = widget.supplier;
    _name = TextEditingController(text: s?.name ?? '');
    _contactPerson = TextEditingController(text: s?.contactPerson ?? '');
    _phone = TextEditingController(text: s?.phone ?? '');
    _email = TextEditingController(text: s?.email ?? '');
    _address = TextEditingController(text: s?.address ?? '');
    _paymentTerms = TextEditingController(text: s?.paymentTerms ?? '');
    _notes = TextEditingController(text: s?.notes ?? '');
    _supplierType = s?.supplierType ?? SupplierType.local;
    _status = s?.status ?? SupplierStatus.active;
  }

  @override
  void dispose() {
    for (final c in [_name, _contactPerson, _phone, _email, _address, _paymentTerms, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final now = DateTime.now();

    final supplier = Supplier(
      id: widget.supplier?.id ?? '',
      businessId: widget.supplier?.businessId ?? userId,
      name: _name.text.trim(),
      contactPerson: _contactPerson.text.trim().isEmpty ? null : _contactPerson.text.trim(),
      phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      email: _email.text.trim().isEmpty ? null : _email.text.trim(),
      address: _address.text.trim().isEmpty ? null : _address.text.trim(),
      supplierType: _supplierType,
      paymentTerms: _paymentTerms.text.trim().isEmpty ? null : _paymentTerms.text.trim(),
      outstandingBalance: widget.supplier?.outstandingBalance ?? 0,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      status: _status,
      createdAt: widget.supplier?.createdAt ?? now,
      updatedAt: now,
      createdBy: widget.supplier?.createdBy ?? userId,
    );

    final controller = ref.read(supplierFormControllerProvider.notifier);
    if (widget.isEditing) {
      controller.update(supplier);
    } else {
      controller.create(supplier);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete supplier?'),
        content: Text('This will permanently delete "${widget.supplier!.name}".'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(supplierFormControllerProvider.notifier).delete(widget.supplier!.id);
            },
            child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(supplierFormControllerProvider);
    final isLoading = formState is SupplierFormLoading;

    ref.listen<SupplierFormState>(supplierFormControllerProvider, (previous, next) {
      if (next is SupplierFormSuccess) {
        Navigator.of(context).pop();
      } else if (next is SupplierFormError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.failure.message)),
        );
      } else if (next is SupplierFormInitial && previous is SupplierFormLoading) {
        Navigator.of(context).pop();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Supplier' : 'Add Supplier'),
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
                decoration: const InputDecoration(labelText: 'Supplier name *'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(controller: _contactPerson, decoration: const InputDecoration(labelText: 'Contact person')),
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

              Text('Supplier Type', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                children: SupplierType.values.map((type) {
                  return ChoiceChip(
                    label: Text(type.label),
                    selected: _supplierType == type,
                    onSelected: (_) => setState(() => _supplierType = type),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),

              TextFormField(
                controller: _paymentTerms,
                decoration: const InputDecoration(labelText: 'Payment terms (e.g. Net 30)'),
              ),
              const SizedBox(height: AppSpacing.lg),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active'),
                value: _status == SupplierStatus.active,
                onChanged: (value) {
                  setState(() => _status = value ? SupplierStatus.active : SupplierStatus.inactive);
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
                      : Text(widget.isEditing ? 'Save Changes' : 'Create Supplier'),
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
