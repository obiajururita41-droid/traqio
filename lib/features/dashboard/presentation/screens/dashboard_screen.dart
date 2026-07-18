import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:traqio/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:traqio/features/dashboard/presentation/widgets/low_stock_section.dart';
import 'package:traqio/features/dashboard/presentation/widgets/performance_section.dart';
import 'package:traqio/features/dashboard/presentation/widgets/quick_actions_section.dart';
import 'package:traqio/features/dashboard/presentation/widgets/recent_activity_section.dart';
import 'package:traqio/features/dashboard/presentation/widgets/sales_chart_card.dart';
import 'package:traqio/features/dashboard/presentation/widgets/shipment_overview_section.dart';
import 'package:traqio/features/dashboard/presentation/widgets/stat_card.dart';
import 'package:traqio/features/stock_movements/presentation/providers/inventory_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final valuationAsync = ref.watch(stockValuationProvider);
    final currency = NumberFormat.currency(symbol: '₦', decimalDigits: 0);
    final width = MediaQuery.sizeOf(context).width;
    final statColumns = width > 900 ? 4 : (width > 600 ? 2 : 1);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardSummaryProvider);
            ref.invalidate(salesChartProvider);
            ref.invalidate(recentActivityProvider);
            ref.invalidate(shipmentOverviewProvider);
            ref.invalidate(lowStockProductsProvider);
            ref.invalidate(performanceSummaryProvider);
            ref.invalidate(stockValuationProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const DashboardHeader(),
                const SizedBox(height: AppSpacing.xxl),
                summaryAsync.when(
                  data: (summary) => GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: statColumns,
                    mainAxisSpacing: AppSpacing.lg,
                    crossAxisSpacing: AppSpacing.lg,
                    childAspectRatio: statColumns == 1 ? 2.4 : 1.4,
                    children: [
                      StatCard(
                        icon: Icons.point_of_sale_rounded,
                        title: summary.todaysSales.title,
                        value: summary.todaysSales.value,
                        description: summary.todaysSales.description,
                        percentageChange: summary.todaysSales.percentageChange,
                        isPositive: summary.todaysSales.isPositive,
                        accentColor: theme.colorScheme.primary,
                      ),
                      // Inventory Value — now backed by real stock valuation
                      valuationAsync.when(
                        data: (valuation) => StatCard(
                          icon: Icons.inventory_2_rounded,
                          title: 'Inventory Value',
                          value: currency.format(valuation.totalStockValue),
                          description: '${valuation.totalProductCount} products tracked',
                          percentageChange: 0,
                          isPositive: true,
                          accentColor: Colors.blue,
                        ),
                        loading: () => const _CardSkeleton(),
                        error: (e, st) => const StatCard(
                          icon: Icons.inventory_2_rounded,
                          title: 'Inventory Value',
                          value: '—',
                          description: 'Could not load',
                          percentageChange: 0,
                          isPositive: true,
                          accentColor: Colors.blue,
                        ),
                      ),
                      // Low Stock Alerts — now backed by real product counts
                      valuationAsync.when(
                        data: (valuation) => StatCard(
                          icon: Icons.warning_amber_rounded,
                          title: 'Low Stock Alerts',
                          value: '${valuation.lowStockCount}',
                          description: 'products need restocking',
                          percentageChange: 0,
                          isPositive: valuation.lowStockCount == 0,
                          accentColor: Colors.orange,
                        ),
                        loading: () => const _CardSkeleton(),
                        error: (e, st) => const _CardSkeleton(),
                      ),
                      StatCard(
                        icon: Icons.receipt_long_rounded,
                        title: summary.outstandingInvoices.title,
                        value: summary.outstandingInvoices.value,
                        description: summary.outstandingInvoices.description,
                        percentageChange: summary.outstandingInvoices.percentageChange,
                        isPositive: summary.outstandingInvoices.isPositive,
                        accentColor: Colors.red,
                      ),
                    ],
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, st) => Text('Could not load summary: $e'),
                ),
                const SizedBox(height: AppSpacing.xxl),
                const SalesChartCard(),
                const SizedBox(height: AppSpacing.xxl),
                const RecentActivitySection(),
                const SizedBox(height: AppSpacing.xxl),
                const ShipmentOverviewSection(),
                const SizedBox(height: AppSpacing.xxl),
                const LowStockSection(),
                const SizedBox(height: AppSpacing.xxl),
                const QuickActionsSection(),
                const SizedBox(height: AppSpacing.xxl),
                const PerformanceSection(),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
