import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/suppliers/domain/entities/supplier.dart';
import 'package:traqio/features/suppliers/domain/entities/supplier_enums.dart';
import 'package:traqio/features/suppliers/presentation/providers/supplier_providers.dart';
import 'package:traqio/features/suppliers/presentation/screens/supplier_form_screen.dart';

class SupplierLedgerScreen extends ConsumerWidget {
  final Supplier supplier;
  const SupplierLedgerScreen({super.key, required this.supplier});

  IconData _iconFor(SupplierLedgerEntryType type) {
    switch (type) {
      case SupplierLedgerEntryType.purchase: return Icons.shopping_cart_checkout_rounded;
      case SupplierLedgerEntryType.payment: return Icons.payments_rounded;
      case SupplierLedgerEntryType.debitNote: return Icons.undo_rounded;
      case SupplierLedgerEntryType.adjustment: return Icons.tune_rounded;
      case SupplierLedgerEntryType.openingBalance: return Icons.flag_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ledgerAsync = ref.watch(supplierLedgerProvider(supplier.id));
    final currency = NumberFormat.currency(symbol: '₦', decimalDigits: 0);
    final dateFormat = DateFormat('d MMM y, h:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text(supplier.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => SupplierFormScreen(supplier: supplier)),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('You Owe',
                              style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
                          const SizedBox(height: 4),
                          Text(currency.format(supplier.outstandingBalance),
                              style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
                        ],
                      ),
                    ),
                    if (supplier.paymentTerms != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Payment Terms',
                              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
                          const SizedBox(height: 4),
                          Text(supplier.paymentTerms!,
                              style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ledgerAsync.when(
                data: (entries) {
                  if (entries.isEmpty) {
                    return Center(
                      child: Text(
                        'No transactions yet',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async => ref.invalidate(supplierLedgerProvider(supplier.id)),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      itemCount: entries.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        // Credit = you now owe more (purchase received).
                        // Debit = you owe less (payment made).
                        final isCredit = entry.direction == SupplierLedgerDirection.credit;
                        final color = isCredit ? theme.colorScheme.error : Colors.green;
                        return Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                            border: Border.all(color: theme.colorScheme.outline),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                                child: Icon(_iconFor(entry.entryType), color: color, size: 20),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(entry.entryType.label, style: theme.textTheme.titleMedium),
                                    const SizedBox(height: 2),
                                    Text(
                                      dateFormat.format(entry.createdAt),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${isCredit ? '+' : '-'}${currency.format(entry.amount)}',
                                style: theme.textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Could not load ledger: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
