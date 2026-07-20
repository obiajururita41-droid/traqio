import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/customers/domain/entities/customer.dart';
import 'package:traqio/features/customers/presentation/providers/customer_providers.dart';
import 'package:traqio/features/products/domain/entities/product.dart';
import 'package:traqio/features/products/presentation/providers/product_providers.dart';
import 'package:traqio/features/sales_orders/domain/entities/sales_order.dart';
import 'package:traqio/features/sales_orders/domain/entities/sales_order_inputs.dart';
import 'package:traqio/features/sales_orders/presentation/providers/sales_order_form_controller.dart';

class _LineItemDraft {
  Product? product;
  final TextEditingController quantityController = TextEditingController(text: '1');
  final TextEditingController priceController = TextEditingController();
  final TextEditingController taxController = TextEditingController(text: '0');

  double get quantity => double.tryParse(quantityController.text.trim()) ?? 0;
  double get price => double.tryParse(priceController.text.trim()) ?? 0;
  double get tax => double.tryParse(taxController.text.trim()) ?? 0;
  double get lineTotal => quantity * price * (1 + tax / 100);

  void dispose() {
    quantityController.dispose();
    priceController.dispose();
    taxController.dispose();
  }
}

class SalesOrderFormScreen extends ConsumerStatefulWidget {
  final SalesOrder? existing;
  const SalesOrderFormScreen({super.key, this.existing});

  bool get isEditing => existing != null;

  @override
  ConsumerState<SalesOrderFormScreen> createState() => _SalesOrderFormScreenState();
}

class _SalesOrderFormScreenState extends ConsumerState<SalesOrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _soNumberController;
  late final TextEditingController _notesController;
  Customer? _selectedCustomer;
  DateTime _orderDate = DateTime.now();
  DateTime? _expectedDeliveryDate;
  final List<_LineItemDraft> _items = [];

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _soNumberController = TextEditingController(
      text: existing?.soNumber ?? 'SO-${DateTime.now().millisecondsSinceEpoch % 100000}',
    );
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _orderDate = existing?.orderDate ?? DateTime.now();
    _expectedDeliveryDate = existing?.expectedDeliveryDate;

    if (existing != null) {
      for (final item in existing.items) {
        final draft = _LineItemDraft();
        draft.quantityController.text = item.quantityOrdered.toString();
        draft.priceController.text = item.unitPrice.toString();
        draft.taxController.text = item.taxRate.toString();
        _items.add(draft);
      }
    } else {
      _items.add(_LineItemDraft());
    }
  }

  @override
  void dispose() {
    _soNumberController.dispose();
    _notesController.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  double get _subtotal => _items.fold(0, (sum, item) => sum + (item.quantity * item.price));
  double get _taxTotal =>
      _items.fold(0, (sum, item) => sum + (item.quantity * item.price * item.tax / 100));
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
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a customer first')),
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
        .map((item) => SalesOrderItemInput(
              productId: item.product!.id,
              quantityOrdered: item.quantity,
              unitPrice: item.price,
              taxRate: item.tax,
            ))
        .toList();

    final controller = ref.read(salesOrderFormControllerProvider.notifier);
    if (widget.isEditing) {
      controller.update(
        id: widget.existing!.id,
        customerId: _selectedCustomer!.id,
        orderDate: _orderDate,
        expectedDeliveryDate: _expectedDeliveryDate,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        items: itemInputs,
      );
    } else {
      controller.create(
        customerId: _selectedCustomer!.id,
        soNumber: _soNumberController.text.trim(),
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
    final formState = ref.watch(salesOrderFormControllerProvider);
    final isLoading = formState is SalesOrderFormLoading;
    final customersAsync = ref.watch(customersProvider);
    final productsAsync = ref.watch(productsProvider);
    final currency = NumberFormat.currency(symbol: '₦', decimalDigits: 0);

    ref.listen<SalesOrderFormState>(salesOrderFormControllerProvider, (previous, next) {
      if (next is SalesOrderFormSuccess) {
        Navigator.of(context).pop();
      } else if (next is SalesOrderFormError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.failure.message)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'Edit Sales Order' : 'New Sale')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              TextFormField(
                controller: _soNumberController,
                enabled: !widget.isEditing,
                decoration: const InputDecoration(labelText: 'SO Number *'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              customersAsync.when(
                data: (customers) {
                  _selectedCustomer ??= widget.existing != null
                      ? customers.where((c) => c.id == widget.existing!.customerId).firstOrNull
                      : null;
                  return DropdownButtonFormField<Customer>(
                    initialValue: _selectedCustomer,
                    decoration: const InputDecoration(labelText: 'Customer *'),
                    items: customers
                        .map((c) => DropdownMenuItem(value: c, child: Text(c.name, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (c) => setState(() => _selectedCustomer = c),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, st) => Text('Could not load customers: $e'),
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
                    initialDate: _expectedDeliveryDate ?? DateTime.now().add(const Duration(days: 3)),
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
                      : Text(widget.isEditing ? 'Save Changes' : 'Create Sales Order'),
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
                    if (p != null && draft.priceController.text.isEmpty) {
                      draft.priceController.text = p.sellingPrice.toString();
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
                  controller: draft.priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Unit price'),
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
