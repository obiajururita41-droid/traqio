import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/invoices/domain/entities/invoice_enums.dart';
import 'package:traqio/features/invoices/presentation/providers/invoice_providers.dart';
import 'package:traqio/features/invoices/presentation/screens/invoice_detail_screen.dart';
import 'package:traqio/features/invoices/presentation/widgets/invoice_card.dart';

class InvoiceListScreen extends ConsumerStatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  ConsumerState<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends ConsumerState<InvoiceListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(invoiceListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final invoicesAsync = ref.watch(invoiceListProvider);
    final statusFilter = ref.watch(invoiceStatusFilterProvider);
    final newestFirst = ref.watch(invoiceNewestFirstProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        actions: [
          IconButton(
            icon: Icon(newestFirst ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded),
            tooltip: 'Sort by date',
            onPressed: () {
              ref.read(invoiceNewestFirstProvider.notifier).state = !newestFirst;
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search by invoice number',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      ref.read(invoiceSearchQueryProvider.notifier).state = value;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _FilterChip(
                          label: 'All',
                          selected: statusFilter == null,
                          onSelected: () => ref.read(invoiceStatusFilterProvider.notifier).state = null,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        for (final status in InvoiceStatus.values) ...[
                          _FilterChip(
                            label: status.label,
                            selected: statusFilter == status,
                            onSelected: () => ref.read(invoiceStatusFilterProvider.notifier).state = status,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: invoicesAsync.when(
                data: (invoices) {
                  if (invoices.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.receipt_long_rounded,
                              size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                          const SizedBox(height: AppSpacing.md),
                          Text('No invoices yet', style: theme.textTheme.titleMedium),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Generate an invoice from a fulfilled sales order',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => ref.read(invoiceListProvider.notifier).refresh(),
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      itemCount: invoices.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        if (index == invoices.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final invoice = invoices[index];
                        return InvoiceCard(
                          invoice: invoice,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => InvoiceDetailScreen(invoiceId: invoice.id),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Could not load invoices: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({required this.label, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}
