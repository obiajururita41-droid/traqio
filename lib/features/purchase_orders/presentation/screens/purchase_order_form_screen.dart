import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/products/domain/entities/product.dart';
import 'package:traqio/features/products/presentation/providers/product_providers.dart';
import 'package:traqio/features/purchase_orders/domain/entities/purchase_order.dart';
import 'package:traqio/features/purchase_orders/domain/entities/purchase_order_inputs.dart';
import 'package:traqio/features/purchase_orders/presentation/providers/purchase_order_form_controller.dart';
import 'package:traqio/features/suppliers/domain/entities/supplier.dart';
import 'package:traqio/features/suppliers/presentation/providers/supplier_providers.dart';

class _LineItemDraft {
  Product? product;
  final TextEditingController quantityController = TextEditingController(text: '1');
  final TextEditingController costController = TextEditingController();
  final TextEditingController taxController = TextEditingController(text: '0');

  double get quantity => double.tryParse(quantityController.text.trim()) ?? 0;
  double get cost => double.tryParse(costController.text.trim()) ?? 0;
  double get tax => double.tryParse(taxController.text.trim()) ?? 0;
  double get lineTotal => quantity * cost * (1 + tax / 100);

  void dispose() {
    quantityController.dispose();
    costController.dispose();
    taxController.dispose();
  }
}

class PurchaseOrderFormScreen extends ConsumerStatefulWidget {
  final PurchaseOrder? existing;
  const PurchaseOrderFormScreen({super.key, this.existing});

  bool get isEditing => existing != null;

  @override
  ConsumerState<PurchaseOrderFormScreen> createState() => _PurchaseOrderFormScreenState();
}

class _PurchaseOrderFormScreenState extends ConsumerState<PurchaseOrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _poNumberController;
  late final TextEditingController _notesController;
  Supplier? _selectedSupplier;
  DateTime _orderDate = DateTime.now();
  DateTime? _expectedDeliveryDate;
  final List<_LineItemDraft> _items = [];

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _poNumberController = TextEditingController(
      text: existing?.poNumber ?? 'PO-${DateTime.now().millisecondsSinceEpoch % 100000}',
    );
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _orderDate = existing?.orderDate ?? DateTime.now();
    _expectedDeliveryDate = existing?.expectedDeliveryDate;

    if (existing != null) {
      for (final item in existing.items) {
        final draft = _LineItemDraft();
        draft.quantityController.text = item.quantityOrdered.toString();
        draft.costController.text = item.unitCost.toString();
        draft.taxController.text = item.taxRate.toString();
        _items.add(draft);
      }
    } else {
      _items.add(_LineItemDraft());
    }
  }

  @override
  void dispose() {
    _poNumberController.dispose();
    _notesController.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  double get _subtotal => _items.fold(0, (sum, item) => sum + (item.quantity * item.cost));
  double get _taxTotal =>
      _items.fold(0, (sum, item) => sum + (item.quantity * item.cost * item.tax / 100));
  double get _grandTotal => _subtotal + _taxTotal;

  void _addLineItem() {
    setState(() => _items.add(_LineItemDraft()));
  }

  void _removeLineItem(int index) {
    setState(() {
      _items[index].dispose();
      _items.removeAt(index);
    });
  }

  void _submit() {
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a supplier first')),
      );
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_items.any((item) => item.product == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a product for every line item')),
      );
      return;
    }

    final itemInputs = _items
        .map((item) => PurchaseOrderItemInput(
              productId: item.product!.id,
              quantityOrdered: item.quantity,
              unitCost: item.cost,
              taxRate: item.tax,
            ))
        .toList();

    final controller = ref.read(purchaseOrderFormControllerProvider.notifier);
    if (widget.isEditing) {
      controller.update(
        id: widget.existing!.id,
        supplierId: _selectedSupplier!.id,
        orderDate: _orderDate,
        expectedDeliveryDate: _expectedDeliveryDate,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        items: itemInputs,
      );
    } else {
      controller.create(
        supplierId: _selectedSupplier!.id,
        poNumber: _poNumberController.text.trim(),
        orderDate: _orderDate,
        expectedDeliveryDate: _expectedDeliveryDate,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        items: itemInputs,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formState = ref.watch(purchaseOrderFormControllerProvider);
    final isLoading = formState is PurchaseOrderFormLoading;
    final suppliersAsync = ref.watch(suppliersProvider);
    final productsAsync = ref.watch(productsProvider);
    final currency = NumberFormat.currency(symbol: '₦', decimalDigits: 0);

    ref.listen<PurchaseOrderFormState>(purchaseOrderFormControllerProvider, (previous, next) {
      if (next is PurchaseOrderFormSuccess) {
        Navigator.of(context).pop();
      } else if (next is PurchaseOrderFormError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.failure.message)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'Edit Purchase Order' : 'Create Purchase Order')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              TextFormField(
                controller: _poNumberController,
                enabled: !widget.isEditing,
                decoration: const InputDecoration(labelText: 'PO Number *'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              suppliersAsync.when(
                data: (suppliers) {
                  _selectedSupplier ??= widget.existing != null
                      ? suppliers.where((s) => s.id == widget.existing!.supplierId).firstOrNull
                      : null;
                  return DropdownButtonFormField<Supplier>(
                    initialValue: _selectedSupplier,
                    decoration: const InputDecoration(labelText: 'Supplier *'),
                    items: suppliers
                        .map((s) => DropdownMenuItem(value: s, child: Text(s.name, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (s) => setState(() => _selectedSupplier = s),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, st) => Text('Could not load suppliers: $e'),
              ),
              const SizedBox(height: AppSpacing.md),

              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context, initialDate: _orderDate,
                    firstDate: DateTime(2020), lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _orderDate = picked);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Order date'),
                  child: Text(DateFormat('d MMM y').format(_orderDate)),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _expectedDeliveryDate ?? DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(), lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _expectedDeliveryDate = picked);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Expected delivery (optional)'),
                  child: Text(_expectedDeliveryDate == null
                      ? 'Not set'
                      : DateFormat('d MMM y').format(_expectedDeliveryDate!)),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Line Items', style: theme.textTheme.titleMedium),
                  TextButton.icon(
                    onPressed: _addLineItem,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Item'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              productsAsync.when(
                data: (products) => Column(
                  children: [
                    for (int i = 0; i < _items.length; i++)
                      _LineItemRow(
                        products: products,
                        draft: _items[i],
                        onRemove: _items.length > 1 ? () => _removeLineItem(i) : null,
                        onChanged: () => setState(() {}),
                      ),
                  ],
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, st) => Text('Could not load products: $e'),
              ),

              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Column(
                  children: [
                    _TotalRow(label: 'Subtotal', value: currency.format(_subtotal)),
                    _TotalRow(label: 'Tax', value: currency.format(_taxTotal)),
                    const Divider(),
                    _TotalRow(label: 'Total', value: currency.format(_grandTotal), isBold: true),
                  ],
                ),
              ),

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
                      : Text(widget.isEditing ? 'Save Changes' : 'Create Purchase Order'),
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

class _LineItemRow extends StatelessWidget {
  final List<Product> products;
  final _LineItemDraft draft;
  final VoidCallback? onRemove;
  final VoidCallback onChanged;

  const _LineItemRow({
    required this.products,
    required this.draft,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<Product>(
                  initialValue: draft.product,
                  decoration: const InputDecoration(labelText: 'Product'),
                  items: products
                      .map((p) => DropdownMenuItem(value: p, child: Text(p.name, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (p) {
                    draft.product = p;
                    if (p != null && draft.costController.text.isEmpty) {
                      draft.costController.text = p.costPrice.toString();
                    }
                    onChanged();
                  },
                ),
              ),
              if (onRemove != null)
                IconButton(icon: const Icon(Icons.close), onPressed: onRemove),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: draft.quantityController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Qty'),
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextFormField(
                  controller: draft.costController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Unit cost'),
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextFormField(
                  controller: draft.taxController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Tax %'),
                  onChanged: (_) => onChanged(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  const _TotalRow({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    final style = isBold
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }
}
