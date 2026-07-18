import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/dashboard/presentation/providers/dashboard_providers.dart';

class ShipmentOverviewSection extends ConsumerWidget {
  const ShipmentOverviewSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final shipmentAsync = ref.watch(shipmentOverviewProvider);

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
          Text('Shipment Overview', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.lg),
          shipmentAsync.when(
            data: (overview) => Row(
              children: [
                Expanded(child: _ShipmentTile(label: 'Pending', count: overview.pending, color: Colors.orange, icon: Icons.hourglass_empty_rounded)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _ShipmentTile(label: 'In Transit', count: overview.inTransit, color: Colors.blue, icon: Icons.local_shipping_outlined)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _ShipmentTile(label: 'Delivered', count: overview.delivered, color: Colors.green, icon: Icons.check_circle_outline)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _ShipmentTile(label: 'Delayed', count: overview.delayed, color: Colors.red, icon: Icons.warning_amber_rounded)),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Text('Could not load shipments: $e'),
          ),
        ],
      ),
    );
  }
}

class _ShipmentTile extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _ShipmentTile({required this.label, required this.count, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppSpacing.sm),
          Text('$count', style: theme.textTheme.titleLarge),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}
