import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/dashboard/domain/entities/activity_item.dart';
import 'package:traqio/features/dashboard/presentation/providers/dashboard_providers.dart';

class RecentActivitySection extends ConsumerWidget {
  const RecentActivitySection({super.key});

  IconData _iconFor(ActivityType type) {
    switch (type) {
      case ActivityType.productAdded:
        return Icons.inventory_2_outlined;
      case ActivityType.invoiceCreated:
        return Icons.receipt_long_outlined;
      case ActivityType.paymentReceived:
        return Icons.payments_outlined;
      case ActivityType.purchaseOrderReceived:
        return Icons.local_shipping_outlined;
      case ActivityType.shipmentDelivered:
        return Icons.check_circle_outline;
    }
  }

  String _timeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activityAsync = ref.watch(recentActivityProvider);

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
          Text('Recent Activity', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.lg),
          activityAsync.when(
            data: (items) => Column(
              children: [
                for (final item in items) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_iconFor(item.type), size: 18, color: theme.colorScheme.onPrimaryContainer),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title, style: theme.textTheme.titleMedium),
                            const SizedBox(height: 2),
                            Text(
                              item.subtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _timeAgo(item.timestamp),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  if (item != items.last) const SizedBox(height: AppSpacing.lg),
                ],
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Text('Could not load activity: $e'),
          ),
        ],
      ),
    );
  }
}
