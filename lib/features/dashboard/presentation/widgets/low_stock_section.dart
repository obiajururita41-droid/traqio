import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/dashboard/presentation/providers/dashboard_providers.dart';

class LowStockSection extends ConsumerWidget {
  const LowStockSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lowStockAsync = ref.watch(lowStockProductsProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Low Stock', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.lg),
          lowStockAsync.when(
            data: (products) => Column(
              children: [
                for (final product in products) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name, style: theme.textTheme.titleMedium),
                            const SizedBox(height: 2),
                            Text(
                              '${product.currentQuantity} left · min ${product.minimumQuantity}',
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Restock ${product.name} — coming soon')),
                          );
                        },
                        child: const Text('Restock'),
                      ),
                    ],
                  ),
                  if (product != products.last) const SizedBox(height: AppSpacing.md),
                ],
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Text('Could not load low stock: $e'),
          ),
        ],
      ),
    );
  }
}
