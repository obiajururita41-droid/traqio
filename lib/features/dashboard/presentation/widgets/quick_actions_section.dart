import 'package:flutter/material.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/customers/presentation/screens/customer_list_screen.dart';
import 'package:traqio/features/invoices/presentation/screens/invoice_list_screen.dart';
import 'package:traqio/features/payments/presentation/screens/payment_list_screen.dart';
import 'package:traqio/features/business_members/presentation/screens/team_screen.dart';
import 'package:traqio/features/products/presentation/screens/product_list_screen.dart';
import 'package:traqio/features/purchase_orders/presentation/screens/purchase_order_list_screen.dart';
import 'package:traqio/features/sales_orders/presentation/screens/sales_order_list_screen.dart';
import 'package:traqio/features/stock_movements/presentation/screens/movement_history_screen.dart';
import 'package:traqio/features/suppliers/presentation/screens/supplier_list_screen.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final columns = width > 600 ? 4 : 3;

    final actions = [
      _QuickAction(icon: Icons.point_of_sale_rounded, label: 'New Sale', onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SalesOrderListScreen()));
      }),
      _QuickAction(icon: Icons.add_box_rounded, label: 'Add Product', onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProductListScreen()));
      }),
      _QuickAction(icon: Icons.add_circle_outline_rounded, label: 'Add Stock', onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MovementHistoryScreen()));
      }),
      _QuickAction(icon: Icons.receipt_long_rounded, label: 'Invoices', onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InvoiceListScreen()));
      }),
      _QuickAction(icon: Icons.person_add_alt_rounded, label: 'Add Customer', onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CustomerListScreen()));
      }),
      _QuickAction(icon: Icons.local_shipping_rounded, label: 'Suppliers', onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SupplierListScreen()));
      }),
      _QuickAction(icon: Icons.shopping_cart_checkout_rounded, label: 'Create P.O.', onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PurchaseOrderListScreen()));
      }),
      _QuickAction(icon: Icons.payments_rounded, label: 'Payments', onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaymentListScreen()));
      }),
      _QuickAction(icon: Icons.map_rounded, label: 'Track Shipment', onTap: () => _comingSoon(context, 'Track Shipment')),
      _QuickAction(icon: Icons.bar_chart_rounded, label: 'View Reports', onTap: () => _comingSoon(context, 'View Reports')),
      _QuickAction(icon: Icons.people_alt_rounded, label: 'Team', onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TeamScreen()));
      }),
    ];

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
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                onTap: action.onTap,
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

  static void _comingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label — coming soon')),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});
}
