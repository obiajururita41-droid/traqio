import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/customers/domain/entities/customer.dart';
import 'package:traqio/features/customers/domain/entities/customer_enums.dart';
import 'package:traqio/features/customers/presentation/providers/customer_providers.dart';
import 'package:traqio/features/customers/presentation/screens/customer_form_screen.dart';

class CustomerLedgerScreen extends ConsumerWidget {
  final Customer customer;
  const CustomerLedgerScreen({super.key, required this.customer});

  IconData _iconFor(LedgerEntryType type) {
    switch (type) {
      case LedgerEntryType.sale: return Icons.point_of_sale_rounded;
      case LedgerEntryType.payment: return Icons.payments_rounded;
      case LedgerEntryType.creditNote: return Icons.undo_rounded;
      case LedgerEntryType.adjustment: return Icons.tune_rounded;
      case LedgerEntryType.openingBalance: return Icons.flag_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ledgerAsync = ref.watch(customerLedgerProvider(customer.id));
    final currency = NumberFormat.currency(symbol: '₦', decimalDigits: 0);
    final dateFormat = DateFormat('d MMM y, h:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text(customer.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => CustomerFormScreen(customer: customer)),
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
                          Text('Outstanding Balance',
                              style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
                          const SizedBox(height: 4),
                          Text(currency.format(customer.outstandingBalance),
                              style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Credit Limit',
                            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
                        const SizedBox(height: 4),
                        Text(currency.format(customer.creditLimit),
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
                    onRefresh: () async => ref.invalidate(customerLedgerProvider(customer.id)),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      itemCount: entries.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        final isDebit = entry.direction == LedgerDirection.debit;
                        final color = isDebit ? theme.colorScheme.error : Colors.green;
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
                                '${isDebit ? '+' : '-'}${currency.format(entry.amount)}',
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
