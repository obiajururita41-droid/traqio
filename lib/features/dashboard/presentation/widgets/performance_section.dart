import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/dashboard/presentation/providers/dashboard_providers.dart';

class PerformanceSection extends ConsumerWidget {
  const PerformanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final performanceAsync = ref.watch(performanceSummaryProvider);
    final currency = NumberFormat.currency(symbol: '₦', decimalDigits: 0);

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
          Text('Performance', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.lg),
          performanceAsync.when(
            data: (perf) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: _MoneyStat(label: 'Monthly Profit', value: currency.format(perf.monthlyProfit), color: Colors.green)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _MoneyStat(label: 'Monthly Expenses', value: currency.format(perf.monthlyExpenses), color: Colors.red)),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Top Selling Products', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                for (final product in perf.topProducts)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        Expanded(child: Text(product.name, style: theme.textTheme.bodyMedium)),
                        Text('${product.unitsSold} sold', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
                Text('Top Customers', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                for (final customer in perf.topCustomers)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        Expanded(child: Text(customer.name, style: theme.textTheme.bodyMedium)),
                        Text(currency.format(customer.totalSpent), style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                      ],
                    ),
                  ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Text('Could not load performance: $e'),
          ),
        ],
      ),
    );
  }
}

class _MoneyStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MoneyStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.titleLarge?.copyWith(color: color)),
        ],
      ),
    );
  }
}
