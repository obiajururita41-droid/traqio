import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/products/domain/entities/product.dart';
import 'package:traqio/features/products/presentation/providers/product_form_controller.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final Product? product;
  const ProductFormScreen({super.key, this.product});

  bool get isEditing => product != null;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _sku;
  late final TextEditingController _barcode;
  late final TextEditingController _description;
  late final TextEditingController _brand;
  late final TextEditingController _unitOfMeasure;
  late final TextEditingController _costPrice;
  late final TextEditingController _sellingPrice;
  late final TextEditingController _wholesalePrice;
  late final TextEditingController _retailPrice;
  late final TextEditingController _taxRate;
  late final TextEditingController _currentStock;
  late final TextEditingController _minimumStock;
  late final TextEditingController _reorderLevel;
  late final TextEditingController _manufacturer;
  late final TextEditingController _countryOfOrigin;
  late final TextEditingController _batchNumber;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _sku = TextEditingController(text: p?.sku ?? '');
    _barcode = TextEditingController(text: p?.barcode ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _brand = TextEditingController(text: p?.brand ?? '');
    _unitOfMeasure = TextEditingController(text: p?.unitOfMeasure ?? 'piece');
    _costPrice = TextEditingController(text: p?.costPrice.toString() ?? '');
    _sellingPrice = TextEditingController(text: p?.sellingPrice.toString() ?? '');
    _wholesalePrice = TextEditingController(text: p?.wholesalePrice?.toString() ?? '');
    _retailPrice = TextEditingController(text: p?.retailPrice?.toString() ?? '');
    _taxRate = TextEditingController(text: p?.taxRate?.toString() ?? '');
    _currentStock = TextEditingController(text: p?.currentStock.toString() ?? '0');
    _minimumStock = TextEditingController(text: p?.minimumStock.toString() ?? '0');
    _reorderLevel = TextEditingController(text: p?.reorderLevel.toString() ?? '0');
    _manufacturer = TextEditingController(text: p?.manufacturer ?? '');
    _countryOfOrigin = TextEditingController(text: p?.countryOfOrigin ?? '');
    _batchNumber = TextEditingController(text: p?.batchNumber ?? '');
  }

  @override
  void dispose() {
    for (final c in [
      _name, _sku, _barcode, _description, _brand, _unitOfMeasure,
      _costPrice, _sellingPrice, _wholesalePrice, _retailPrice, _taxRate,
      _currentStock, _minimumStock, _reorderLevel, _manufacturer,
      _countryOfOrigin, _batchNumber,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _parseDouble(String text) => text.trim().isEmpty ? null : double.tryParse(text.trim());

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final now = DateTime.now();

    final product = Product(
      id: widget.product?.id ?? '',
      businessId: widget.product?.businessId ?? userId,
      name: _name.text.trim(),
      sku: _sku.text.trim().isEmpty ? null : _sku.text.trim(),
      barcode: _barcode.text.trim().isEmpty ? null : _barcode.text.trim(),
      description: _description.text.trim().isEmpty ? null : _description.text.trim(),
      brand: _brand.text.trim().isEmpty ? null : _brand.text.trim(),
      unitOfMeasure: _unitOfMeasure.text.trim().isEmpty ? 'piece' : _unitOfMeasure.text.trim(),
      costPrice: _parseDouble(_costPrice.text) ?? 0,
      sellingPrice: _parseDouble(_sellingPrice.text) ?? 0,
      wholesalePrice: _parseDouble(_wholesalePrice.text),
      retailPrice: _parseDouble(_retailPrice.text),
      taxRate: _parseDouble(_taxRate.text),
      currentStock: _parseDouble(_currentStock.text) ?? 0,
      minimumStock: _parseDouble(_minimumStock.text) ?? 0,
      reorderLevel: _parseDouble(_reorderLevel.text) ?? 0,
      manufacturer: _manufacturer.text.trim().isEmpty ? null : _manufacturer.text.trim(),
      countryOfOrigin: _countryOfOrigin.text.trim().isEmpty ? null : _countryOfOrigin.text.trim(),
      batchNumber: _batchNumber.text.trim().isEmpty ? null : _batchNumber.text.trim(),
      createdAt: widget.product?.createdAt ?? now,
      updatedAt: now,
      createdBy: widget.product?.createdBy ?? userId,
      lastModifiedBy: userId,
    );

    final controller = ref.read(productFormControllerProvider.notifier);
    if (widget.isEditing) {
      controller.update(product);
    } else {
      controller.create(product);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text('This will permanently delete "${widget.product!.name}".'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(productFormControllerProvider.notifier).delete(widget.product!.id);
            },
            child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(productFormControllerProvider);
    final isLoading = formState is ProductFormLoading;

    ref.listen<ProductFormState>(productFormControllerProvider, (previous, next) {
      if (next is ProductFormSuccess) {
        Navigator.of(context).pop();
      } else if (next is ProductFormError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.failure.message)),
        );
      } else if (next is ProductFormInitial && previous is ProductFormLoading) {
        // delete completed
        Navigator.of(context).pop();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Product' : 'Add Product'),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: isLoading ? null : _confirmDelete,
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              const _SectionHeader('Core Details'),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Product name *'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _sku, decoration: const InputDecoration(labelText: 'SKU'))),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: TextFormField(controller: _barcode, decoration: const InputDecoration(labelText: 'Barcode'))),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _brand, decoration: const InputDecoration(labelText: 'Brand'))),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: TextFormField(controller: _unitOfMeasure, decoration: const InputDecoration(labelText: 'Unit (e.g. piece, kg, carton)'))),
                ],
              ),

              const _SectionHeader('Pricing'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _costPrice,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Cost price *'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _sellingPrice,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Selling price *'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _wholesalePrice,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Wholesale price'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _retailPrice,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Retail price'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _taxRate,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Tax rate (%)'),
              ),

              const _SectionHeader('Inventory'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _currentStock,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Current stock'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _minimumStock,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Minimum stock'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _reorderLevel,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Reorder level'),
              ),

              const _SectionHeader('Supplier & Origin'),
              TextFormField(controller: _manufacturer, decoration: const InputDecoration(labelText: 'Manufacturer')),
              const SizedBox(height: AppSpacing.md),
              TextFormField(controller: _countryOfOrigin, decoration: const InputDecoration(labelText: 'Country of origin')),

              const _SectionHeader('Tracking'),
              TextFormField(controller: _batchNumber, decoration: const InputDecoration(labelText: 'Batch number')),

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
                      : Text(widget.isEditing ? 'Save Changes' : 'Create Product'),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.md),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          )),
    );
  }
}
