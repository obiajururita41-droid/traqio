import 'package:flutter/material.dart';
import 'package:traqio/core/theme/app_spacing.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  static const _actions = [
    _QuickAction(icon: Icons.point_of_sale_rounded, label: 'New Sale'),
    _QuickAction(icon: Icons.add_box_rounded, label: 'Add Product'),
    _QuickAction(icon: Icons.add_circle_outline_rounded, label: 'Add Stock'),
    _QuickAction(icon: Icons.receipt_long_rounded, label: 'Create Invoice'),
    _QuickAction(icon: Icons.person_add_alt_rounded, label: 'Add Customer'),
    _QuickAction(icon: Icons.shopping_cart_checkout_rounded, label: 'Create P.O.'),
    _QuickAction(icon: Icons.local_shipping_rounded, label: 'Track Shipment'),
    _QuickAction(icon: Icons.bar_chart_rounded, label: 'View Reports'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final columns = width > 600 ? 4 : 3;

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
          Text('Quick Actions', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.lg),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.95,
            ),
            itemCount: _actions.length,
            itemBuilder: (context, index) {
              final action = _actions[index];
              return InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${action.label} — coming soon')),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(action.icon, color: theme.colorScheme.primary, size: 26),
                      const SizedBox(height: AppSpacing.sm),
                      Text(action.label, textAlign: TextAlign.center, style: theme.textTheme.labelMedium),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  const _QuickAction({required this.icon, required this.label});
}
