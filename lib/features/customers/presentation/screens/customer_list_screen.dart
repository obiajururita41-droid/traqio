import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/customers/presentation/providers/customer_providers.dart';
import 'package:traqio/features/customers/presentation/screens/customer_form_screen.dart';
import 'package:traqio/features/customers/presentation/screens/customer_ledger_screen.dart';
import 'package:traqio/features/customers/presentation/widgets/customer_card.dart';

class CustomerListScreen extends ConsumerWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final customersAsync = ref.watch(customersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CustomerFormScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Customer'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search by name, phone, or email',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  ref.read(customerSearchQueryProvider.notifier).state = value;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: customersAsync.when(
                  data: (customers) {
                    if (customers.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people_outline,
                                size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                            const SizedBox(height: AppSpacing.md),
                            Text('No customers yet', style: theme.textTheme.titleMedium),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Tap "Add Customer" to create your first one',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async => ref.invalidate(customersProvider),
                      child: ListView.separated(
                        itemCount: customers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final customer = customers[index];
                          return CustomerCard(
                            customer: customer,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CustomerLedgerScreen(customer: customer),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('Could not load customers: $e')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
