import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/purchase_orders/domain/entities/po_enums.dart';
import 'package:traqio/features/purchase_orders/presentation/providers/purchase_order_providers.dart';
import 'package:traqio/features/purchase_orders/presentation/screens/purchase_order_detail_screen.dart';
import 'package:traqio/features/purchase_orders/presentation/screens/purchase_order_form_screen.dart';
import 'package:traqio/features/purchase_orders/presentation/widgets/po_card.dart';

class PurchaseOrderListScreen extends ConsumerStatefulWidget {
  const PurchaseOrderListScreen({super.key});

  @override
  ConsumerState<PurchaseOrderListScreen> createState() => _PurchaseOrderListScreenState();
}

class _PurchaseOrderListScreenState extends ConsumerState<PurchaseOrderListScreen> {
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
      ref.read(purchaseOrderListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ordersAsync = ref.watch(purchaseOrderListProvider);
    final statusFilter = ref.watch(poStatusFilterProvider);
    final newestFirst = ref.watch(poNewestFirstProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Orders'),
        actions: [
          IconButton(
            icon: Icon(newestFirst ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded),
            tooltip: 'Sort by date',
            onPressed: () {
              ref.read(poNewestFirstProvider.notifier).state = !newestFirst;
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PurchaseOrderFormScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Create P.O.'),
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
                      hintText: 'Search by PO number',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      ref.read(poSearchQueryProvider.notifier).state = value;
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
                          onSelected: () => ref.read(poStatusFilterProvider.notifier).state = null,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        for (final status in PurchaseOrderStatus.values) ...[
                          _FilterChip(
                            label: status.label,
                            selected: statusFilter == status,
                            onSelected: () => ref.read(poStatusFilterProvider.notifier).state = status,
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
              child: ordersAsync.when(
                data: (orders) {
                  if (orders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shopping_cart_checkout_rounded,
                              size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                          const SizedBox(height: AppSpacing.md),
                          Text('No purchase orders yet', style: theme.textTheme.titleMedium),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => ref.read(purchaseOrderListProvider.notifier).refresh(),
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      itemCount: orders.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        if (index == orders.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final po = orders[index];
                        return PoCard(
                          po: po,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PurchaseOrderDetailScreen(poId: po.id),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Could not load purchase orders: $e')),
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
