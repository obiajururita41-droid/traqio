import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/dashboard/domain/entities/chart_period.dart';
import 'package:traqio/features/dashboard/presentation/providers/dashboard_providers.dart';

class SalesChartCard extends ConsumerWidget {
  const SalesChartCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedPeriod = ref.watch(chartPeriodProvider);
    final chartAsync = ref.watch(salesChartProvider);

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
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              Text('Sales Overview', style: theme.textTheme.titleLarge),
              SegmentedButton<ChartPeriod>(
                segments: const [
                  ButtonSegment(value: ChartPeriod.weekly, label: Text('Week')),
                  ButtonSegment(value: ChartPeriod.monthly, label: Text('Month')),
                  ButtonSegment(value: ChartPeriod.yearly, label: Text('Year')),
                ],
                selected: {selectedPeriod},
                showSelectedIcon: false,
                onSelectionChanged: (selection) {
                  ref.read(chartPeriodProvider.notifier).state = selection.first;
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: 220,
            child: chartAsync.when(
              data: (points) {
                if (points.isEmpty) return const Center(child: Text('No data yet'));
                final spots = <FlSpot>[
                  for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].value),
                ];
                return LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= points.length) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(points[index].label, style: theme.textTheme.labelSmall),
                            );
                          },
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: theme.colorScheme.primary,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Could not load chart: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
