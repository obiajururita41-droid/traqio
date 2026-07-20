import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/products/presentation/providers/product_providers.dart';
import 'package:traqio/features/sales_orders/domain/entities/sales_order.dart';
import 'package:traqio/features/sales_orders/domain/entities/sales_order_inputs.dart';
import 'package:traqio/features/sales_orders/domain/entities/sales_order_item.dart';
import 'package:traqio/features/sales_orders/domain/entities/so_enums.dart';
import 'package:traqio/features/sales_orders/presentation/providers/fulfill_order_controller.dart';
import 'package:traqio/features/sales_orders/presentation/providers/sales_order_form_controller.dart';
import 'package:traqio/features/sales_orders/presentation/providers/sales_order_providers.dart';
import 'package:traqio/features/sales_orders/presentation/screens/sales_order_form_screen.dart';
import 'package:traqio/features/sales_orders/presentation/widgets/so_status_badge.dart';

class SalesOrderDetailScreen extends ConsumerWidget {
  final String soId;
  const SalesOrderDetailScreen({super.key, required this.soId});

  void _confirmCancel(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel sales order?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('No')),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(salesOrderFormControllerProvider.notifier).cancel(id);
            },
            child: Text('Yes, cancel', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void _openFulfillSheet(BuildContext context, WidgetRef ref, SalesOrder so) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _FulfillItemsSheet(so: so),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final soAsync = ref.watch(salesOrderDetailProvider(soId));
    final formState = ref.watch(salesOrderFormControllerProvider);
    final isLoading = formState is SalesOrderFormLoading;
    final currency = NumberFormat.currency(symbol: '₦', decimalDigits: 0);
    final dateFormat = DateFormat('d MMM y');

    ref.listen<SalesOrderFormState>(salesOrderFormControllerProvider, (previous, next) {
      if (next is SalesOrderFormError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.failure.message)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: soAsync.whenOrNull(data: (so) => Text(so.soNumber)) ?? const Text('Sales Order'),
      ),
      body: SafeArea(
        child: soAsync.when(
          data: (so) => ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SoStatusBadge(status: so.status),
                  if (so.isOverdue)
                    Text('Overdue', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.error)),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              _InfoRow(label: 'Customer', value: so.customerName ?? '—'),
              _InfoRow(label: 'Order date', value: dateFormat.format(so.orderDate)),
              if (so.expectedDeliveryDate != null)
                _InfoRow(label: 'Expected delivery', value: dateFormat.format(so.expectedDeliveryDate!)),
              if (so.notes != null && so.notes!.isNotEmpty) _InfoRow(label: 'Notes', value: so.notes!),

              const SizedBox(height: AppSpacing.xl),
              Text('Items', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              for (final item in so.items) _ItemRow(item: item, currency: currency),

              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Column(
                  children: [
                    _TotalRow(label: 'Subtotal', value: currency.format(so.subtotal)),
                    _TotalRow(label: 'Tax', value: currency.format(so.taxAmount)),
                    const Divider(),
                    _TotalRow(label: 'Total', value: currency.format(so.totalAmount), isBold: true),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              if (so.canEdit)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => SalesOrderFormScreen(existing: so)),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                  ),
                ),
              if (so.status == SalesOrderStatus.draft) ...[
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : () {
                      ref.read(salesOrderFormControllerProvider.notifier).confirm(so.id);
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Confirm Order'),
                  ),
                ),
              ],
              if (so.canFulfill) ...[
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openFulfillSheet(context, ref, so),
                    icon: const Icon(Icons.local_shipping_outlined),
                    label: const Text('Fulfill Items'),
                  ),
                ),
              ],
              if (so.canCancel) ...[
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : () => _confirmCancel(context, ref, so.id),
                    icon: Icon(Icons.cancel_outlined, color: theme.colorScheme.error),
                    label: Text('Cancel Order', style: TextStyle(color: theme.colorScheme.error)),
                  ),
                ),
              ],
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Could not load sales order: $e')),
        ),
      ),
    );
  }
}

class _FulfillItemsSheet extends ConsumerStatefulWidget {
  final SalesOrder so;
  const _FulfillItemsSheet({required this.so});

  @override
  ConsumerState<_FulfillItemsSheet> createState() => _FulfillItemsSheetState();
}

class _FulfillItemsSheetState extends ConsumerState<_FulfillItemsSheet> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (final item in widget.so.items) {
      if (!item.isFullyFulfilled) {
        _controllers[item.id] = TextEditingController(
          text: item.remainingQuantity.toString(),
        );
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit(Map<String, double> availableStock) {
    final fulfillments = <FulfillmentInput>[];
    for (final entry in _controllers.entries) {
      final qty = double.tryParse(entry.value.text.trim()) ?? 0;
      if (qty > 0) {
        fulfillments.add(FulfillmentInput(itemId: entry.key, quantityToFulfill: qty));
      }
    }
    if (fulfillments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a quantity to fulfill for at least one item')),
      );
      return;
    }

    for (final item in widget.so.items) {
      final controller = _controllers[item.id];
      if (controller == null) continue;
      final qty = double.tryParse(controller.text.trim()) ?? 0;
      final available = availableStock[item.productId];
      if (available != null && qty > available) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(
            '${item.productName ?? "Product"}: only $available in stock, cannot fulfill $qty',
          )),
        );
        return;
      }
    }

    ref.read(fulfillOrderControllerProvider.notifier).fulfill(
          soId: widget.so.id,
          customerId: widget.so.customerId,
          fulfillments: fulfillments,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fulfillState = ref.watch(fulfillOrderControllerProvider);
    final isLoading = fulfillState is FulfillOrderLoading;
    final productsAsync = ref.watch(productsProvider);

    ref.listen<FulfillOrderState>(fulfillOrderControllerProvider, (previous, next) {
      if (next is FulfillOrderSuccess) {
        Navigator.of(context).pop();
      } else if (next is FulfillOrderError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.failure.message)));
      }
    });

    final pendingItems = widget.so.items.where((i) => !i.isFullyFulfilled).toList();

    return productsAsync.when(
      data: (products) {
        final stockByProduct = {for (final p in products) p.id: p.availableStock};

        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.xl, right: AppSpacing.xl, top: AppSpacing.xl,
            bottom: AppSpacing.xl + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Fulfill Items', style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.lg),
              for (final item in pendingItems)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.productName ?? 'Product', style: theme.textTheme.bodyMedium),
                            Text(
                              'Ordered ${item.quantityOrdered.toStringAsFixed(0)} · Remaining ${item.remainingQuantity.toStringAsFixed(0)} · Available ${(stockByProduct[item.productId] ?? 0).toStringAsFixed(0)}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: (stockByProduct[item.productId] ?? 0) < item.remainingQuantity
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 90,
                        child: TextFormField(
                          controller: _controllers[item.id],
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Qty'),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: isLoading ? null : () => _submit(stockByProduct),
                child: isLoading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Confirm Fulfillment'),
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.xxxl),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text('Could not load stock levels: $e'),
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
  final SalesOrderItem item;
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
                Text(item.productName ?? 'Product', style: theme.textTheme.bodyMedium),
                Text(
                  '${item.quantityOrdered.toStringAsFixed(0)} × ${currency.format(item.unitPrice)} · Fulfilled ${item.quantityFulfilled.toStringAsFixed(0)}',
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
