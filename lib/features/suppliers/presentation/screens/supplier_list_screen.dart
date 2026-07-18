import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/suppliers/presentation/providers/supplier_providers.dart';
import 'package:traqio/features/suppliers/presentation/screens/supplier_form_screen.dart';
import 'package:traqio/features/suppliers/presentation/screens/supplier_ledger_screen.dart';
import 'package:traqio/features/suppliers/presentation/widgets/supplier_card.dart';

class SupplierListScreen extends ConsumerWidget {
  const SupplierListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final suppliersAsync = ref.watch(suppliersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Suppliers')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SupplierFormScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Supplier'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search by name, phone, or contact person',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  ref.read(supplierSearchQueryProvider.notifier).state = value;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: suppliersAsync.when(
                  data: (suppliers) {
                    if (suppliers.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_shipping_outlined,
                                size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                            const SizedBox(height: AppSpacing.md),
                            Text('No suppliers yet', style: theme.textTheme.titleMedium),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Tap "Add Supplier" to create your first one',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async => ref.invalidate(suppliersProvider),
                      child: ListView.separated(
                        itemCount: suppliers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final supplier = suppliers[index];
                          return SupplierCard(
                            supplier: supplier,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SupplierLedgerScreen(supplier: supplier),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('Could not load suppliers: $e')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
