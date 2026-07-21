import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/payments/domain/entities/payment_enums.dart';
import 'package:traqio/features/payments/presentation/providers/payment_providers.dart';
import 'package:traqio/features/payments/presentation/screens/payment_detail_screen.dart';
import 'package:traqio/features/payments/presentation/screens/record_payment_screen.dart';
import 'package:traqio/features/payments/presentation/widgets/payment_card.dart';

class PaymentListScreen extends ConsumerStatefulWidget {
  const PaymentListScreen({super.key});

  @override
  ConsumerState<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends ConsumerState<PaymentListScreen> {
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
      ref.read(paymentListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paymentsAsync = ref.watch(paymentListProvider);
    final typeFilter = ref.watch(paymentTypeFilterProvider);
    final newestFirst = ref.watch(paymentNewestFirstProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        actions: [
          IconButton(
            icon: Icon(newestFirst ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded),
            tooltip: 'Sort by date',
            onPressed: () {
              ref.read(paymentNewestFirstProvider.notifier).state = !newestFirst;
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const RecordPaymentScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Record Payment'),
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
                      hintText: 'Search by payment number or reference',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      ref.read(paymentSearchQueryProvider.notifier).state = value;
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
                          selected: typeFilter == null,
                          onSelected: () => ref.read(paymentTypeFilterProvider.notifier).state = null,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        for (final type in PaymentType.values) ...[
                          _FilterChip(
                            label: type.label,
                            selected: typeFilter == type,
                            onSelected: () => ref.read(paymentTypeFilterProvider.notifier).state = type,
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
              child: paymentsAsync.when(
                data: (payments) {
                  if (payments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.payments_outlined,
                              size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                          const SizedBox(height: AppSpacing.md),
                          Text('No payments yet', style: theme.textTheme.titleMedium),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => ref.read(paymentListProvider.notifier).refresh(),
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      itemCount: payments.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        if (index == payments.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final payment = payments[index];
                        return PaymentCard(
                          payment: payment,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PaymentDetailScreen(paymentId: payment.id),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Could not load payments: $e')),
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
