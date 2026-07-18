import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/products/domain/entities/product.dart';
import 'package:traqio/features/products/presentation/providers/product_providers.dart';
import 'package:traqio/features/stock_movements/domain/entities/movement_type.dart';
import 'package:traqio/features/stock_movements/presentation/providers/inventory_providers.dart';

class RecordMovementScreen extends ConsumerStatefulWidget {
  final Product? preselectedProduct;
  const RecordMovementScreen({super.key, this.preselectedProduct});

  @override
  ConsumerState<RecordMovementScreen> createState() => _RecordMovementScreenState();
}

class _RecordMovementScreenState extends ConsumerState<RecordMovementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _unitCostController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _notesController = TextEditingController();

  Product? _selectedProduct;
  MovementType _movementType = MovementType.stockIn;
  AdjustmentReason? _reasonCode;
  DateTime? _expiryDate;

  @override
  void initState() {
    super.initState();
    _selectedProduct = widget.preselectedProduct;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitCostController.dispose();
    _batchNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  MovementDirection get _direction {
    switch (_movementType) {
      case MovementType.stockIn:
      case MovementType.returnMovement:
        return MovementDirection.increase;
      case MovementType.stockOut:
      case MovementType.damaged:
      case MovementType.expired:
      case MovementType.transfer:
        return MovementDirection.decrease;
      case MovementType.adjustment:
        // Adjustment can go either way; default to decrease (correction
        // downward is the more common real-world case: shrinkage found).
        return MovementDirection.decrease;
    }
  }

  bool get _needsReason =>
      _movementType == MovementType.adjustment ||
      _movementType == MovementType.damaged;

  bool get _needsBatchExpiry =>
      _movementType == MovementType.stockIn;

  void _submit() {
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a product first')),
      );
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final quantity = double.tryParse(_quantityController.text.trim()) ?? 0;
    final unitCost = double.tryParse(_unitCostController.text.trim());

    ref.read(movementFormControllerProvider.notifier).submit(
          productId: _selectedProduct!.id,
          movementType: _movementType,
          direction: _direction,
          quantity: quantity,
          unitCost: unitCost,
          reasonCode: _needsReason ? _reasonCode : null,
          batchNumber: _needsBatchExpiry ? _batchNumberController.text.trim() : null,
          expiryDate: _needsBatchExpiry ? _expiryDate : null,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(movementFormControllerProvider);
    final isLoading = formState is MovementFormLoading;
    final productsAsync = ref.watch(productsProvider);

    ref.listen(movementFormControllerProvider, (previous, next) {
      if (next is MovementFormSuccess) {
        Navigator.of(context).pop();
      } else if (next is MovementFormError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.message)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Record Stock Movement')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              Text('Movement Type', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: MovementType.values.map((type) {
                  final selected = _movementType == type;
                  return ChoiceChip(
                    label: Text(type.label),
                    selected: selected,
                    onSelected: (_) => setState(() => _movementType = type),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),

              Text('Product', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              productsAsync.when(
                data: (products) => DropdownButtonFormField<Product>(
                  initialValue: _selectedProduct,
                  decoration: const InputDecoration(hintText: 'Select a product'),
                  items: products.map((p) {
                    return DropdownMenuItem(value: p, child: Text(p.name, overflow: TextOverflow.ellipsis));
                  }).toList(),
                  onChanged: (product) => setState(() => _selectedProduct = product),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, st) => Text('Could not load products: $e'),
              ),
              const SizedBox(height: AppSpacing.lg),

              TextFormField(
                controller: _quantityController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Quantity *'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              TextFormField(
                controller: _unitCostController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Unit cost (optional)'),
              ),

              if (_needsReason) ...[
                const SizedBox(height: AppSpacing.lg),
                Text('Reason', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: AdjustmentReason.values.map((reason) {
                    final selected = _reasonCode == reason;
                    return ChoiceChip(
                      label: Text(reason.label),
                      selected: selected,
                      onSelected: (_) => setState(() => _reasonCode = reason),
                    );
                  }).toList(),
                ),
              ],

              if (_needsBatchExpiry) ...[
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _batchNumberController,
                  decoration: const InputDecoration(labelText: 'Batch number (optional)'),
                ),
                const SizedBox(height: AppSpacing.md),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 365)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _expiryDate = picked);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Expiry date (optional)'),
                    child: Text(_expiryDate == null
                        ? 'Not set'
                        : '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'),
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.lg),
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
                      : const Text('Record Movement'),
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
