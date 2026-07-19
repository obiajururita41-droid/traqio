import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/purchase_orders/domain/entities/po_enums.dart';
import 'package:traqio/features/purchase_orders/domain/entities/purchase_order.dart';
import 'package:traqio/features/purchase_orders/domain/entities/purchase_order_inputs.dart';
import 'package:traqio/features/purchase_orders/domain/entities/purchase_order_item.dart';
import 'package:traqio/features/purchase_orders/presentation/providers/purchase_order_form_controller.dart';
import 'package:traqio/features/purchase_orders/presentation/providers/purchase_order_providers.dart';
import 'package:traqio/features/purchase_orders/presentation/providers/receive_order_controller.dart';
import 'package:traqio/features/purchase_orders/presentation/screens/purchase_order_form_screen.dart';
import 'package:traqio/features/purchase_orders/presentation/widgets/po_status_badge.dart';

class PurchaseOrderDetailScreen extends ConsumerWidget {
  final String poId;
  const PurchaseOrderDetailScreen({super.key, required this.poId});

  void _confirmCancel(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel purchase order?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('No')),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(purchaseOrderFormControllerProvider.notifier).cancel(id);
            },
            child: Text('Yes, cancel', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void _openReceiveSheet(BuildContext context, WidgetRef ref, PurchaseOrder po) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ReceiveItemsSheet(po: po),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final poAsync = ref.watch(purchaseOrderDetailProvider(poId));
    final formState = ref.watch(purchaseOrderFormControllerProvider);
    final isLoading = formState is PurchaseOrderFormLoading;
    final currency = NumberFormat.currency(symbol: '₦', decimalDigits: 0);
    final dateFormat = DateFormat('d MMM y');

    ref.listen<PurchaseOrderFormState>(purchaseOrderFormControllerProvider, (previous, next) {
      if (next is PurchaseOrderFormError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.failure.message)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: poAsync.whenOrNull(data: (po) => Text(po.poNumber)) ?? const Text('Purchase Order'),
      ),
      body: SafeArea(
        child: poAsync.when(
          data: (po) => ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PoStatusBadge(status: po.status),
                  if (po.isOverdue)
                    Text('Overdue', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.error)),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              _InfoRow(label: 'Supplier', value: po.supplierName ?? '—'),
              _InfoRow(label: 'Order date', value: dateFormat.format(po.orderDate)),
              if (po.expectedDeliveryDate != null)
                _InfoRow(label: 'Expected delivery', value: dateFormat.format(po.expectedDeliveryDate!)),
              if (po.notes != null && po.notes!.isNotEmpty) _InfoRow(label: 'Notes', value: po.notes!),

              const SizedBox(height: AppSpacing.xl),
              Text('Items', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              for (final item in po.items) _ItemRow(item: item, currency: currency),

              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Column(
                  children: [
                    _TotalRow(label: 'Subtotal', value: currency.format(po.subtotal)),
                    _TotalRow(label: 'Tax', value: currency.format(po.taxAmount)),
                    const Divider(),
                    _TotalRow(label: 'Total', value: currency.format(po.totalAmount), isBold: true),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              if (po.canEdit)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => PurchaseOrderFormScreen(existing: po)),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                  ),
                ),
              if (po.status == PurchaseOrderStatus.draft) ...[
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : () {
                      ref.read(purchaseOrderFormControllerProvider.notifier).markAsSent(po.id);
                    },
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Mark as Sent'),
                  ),
                ),
              ],
              if (po.canReceive) ...[
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openReceiveSheet(context, ref, po),
                    icon: const Icon(Icons.inventory_2_outlined),
                    label: const Text('Receive Items'),
                  ),
                ),
              ],
              if (po.canCancel) ...[
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : () => _confirmCancel(context, ref, po.id),
                    icon: Icon(Icons.cancel_outlined, color: theme.colorScheme.error),
                    label: Text('Cancel Order', style: TextStyle(color: theme.colorScheme.error)),
                  ),
                ),
              ],
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Could not load purchase order: $e')),
        ),
      ),
    );
  }
}

class _ReceiveItemsSheet extends ConsumerStatefulWidget {
  final PurchaseOrder po;
  const _ReceiveItemsSheet({required this.po});

  @override
  ConsumerState<_ReceiveItemsSheet> createState() => _ReceiveItemsSheetState();
}

class _ReceiveItemsSheetState extends ConsumerState<_ReceiveItemsSheet> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (final item in widget.po.items) {
      if (!item.isFullyReceived) {
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

  void _submit() {
    final receipts = <ReceiptInput>[];
    for (final entry in _controllers.entries) {
      final qty = double.tryParse(entry.value.text.trim()) ?? 0;
      if (qty > 0) {
        receipts.add(ReceiptInput(itemId: entry.key, quantityToReceive: qty));
      }
    }
    if (receipts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a quantity to receive for at least one item')),
      );
      return;
    }
    ref.read(receiveOrderControllerProvider.notifier).receive(
          poId: widget.po.id,
          supplierId: widget.po.supplierId,
          receipts: receipts,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final receiveState = ref.watch(receiveOrderControllerProvider);
    final isLoading = receiveState is ReceiveOrderLoading;

    ref.listen<ReceiveOrderState>(receiveOrderControllerProvider, (previous, next) {
      if (next is ReceiveOrderSuccess) {
        Navigator.of(context).pop();
      } else if (next is ReceiveOrderError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.failure.message)));
      }
    });

    final pendingItems = widget.po.items.where((i) => !i.isFullyReceived).toList();

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.xl, right: AppSpacing.xl, top: AppSpacing.xl,
        bottom: AppSpacing.xl + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Receive Items', style: theme.textTheme.titleLarge),
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
                          'Ordered ${item.quantityOrdered.toStringAsFixed(0)} · Remaining ${item.remainingQuantity.toStringAsFixed(0)}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
            onPressed: isLoading ? null : _submit,
            child: isLoading
                ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Confirm Receipt'),
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
  final PurchaseOrderItem item;
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
                  '${item.quantityOrdered.toStringAsFixed(0)} × ${currency.format(item.unitCost)} · Received ${item.quantityReceived.toStringAsFixed(0)}',
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
