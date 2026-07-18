import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:traqio/features/dashboard/domain/entities/activity_item.dart';
import 'package:traqio/features/dashboard/domain/entities/chart_period.dart';
import 'package:traqio/features/dashboard/domain/entities/dashboard_stat.dart';
import 'package:traqio/features/dashboard/domain/entities/low_stock_product.dart';
import 'package:traqio/features/dashboard/domain/entities/performance_summary.dart';
import 'package:traqio/features/dashboard/domain/entities/sales_chart_point.dart';
import 'package:traqio/features/dashboard/domain/entities/shipment_overview.dart';

/// Currently returns placeholder data. Every method is written so
/// that wiring in real Supabase queries later (once Sales, Inventory,
/// Invoices, and Shipment tables exist) only means editing the body
/// of these methods — nothing else in the app needs to change.
class DashboardRemoteDataSource {
  final SupabaseClient client;
  const DashboardRemoteDataSource(this.client);

  Future<DashboardSummary> getDashboardSummary() async {
    // TODO: replace with real aggregate queries, e.g.
    // client.from('sales_orders').select().gte('created_at', today)
    await Future.delayed(const Duration(milliseconds: 300));
    return const DashboardSummary(
      todaysSales: DashboardStat(
        title: "Today's Sales",
        value: '₦248,500',
        description: 'vs yesterday',
        percentageChange: 12.4,
        isPositive: true,
      ),
      inventoryValue: DashboardStat(
        title: 'Inventory Value',
        value: '₦4,820,000',
        description: 'across all products',
        percentageChange: 3.1,
        isPositive: true,
      ),
      lowStockAlerts: DashboardStat(
        title: 'Low Stock Alerts',
        value: '7',
        description: 'products need restocking',
        percentageChange: 2.0,
        isPositive: false,
      ),
      outstandingInvoices: DashboardStat(
        title: 'Outstanding Invoices',
        value: '₦612,300',
        description: '9 unpaid invoices',
        percentageChange: 5.6,
        isPositive: false,
      ),
    );
  }

  Future<List<SalesChartPoint>> getSalesChart(ChartPeriod period) async {
    await Future.delayed(const Duration(milliseconds: 300));
    switch (period) {
      case ChartPeriod.weekly:
        return const [
          SalesChartPoint(label: 'Mon', value: 120000),
          SalesChartPoint(label: 'Tue', value: 98000),
          SalesChartPoint(label: 'Wed', value: 145000),
          SalesChartPoint(label: 'Thu', value: 132000),
          SalesChartPoint(label: 'Fri', value: 178000),
          SalesChartPoint(label: 'Sat', value: 210000),
          SalesChartPoint(label: 'Sun', value: 95000),
        ];
      case ChartPeriod.monthly:
        return const [
          SalesChartPoint(label: 'Wk 1', value: 620000),
          SalesChartPoint(label: 'Wk 2', value: 780000),
          SalesChartPoint(label: 'Wk 3', value: 690000),
          SalesChartPoint(label: 'Wk 4', value: 910000),
        ];
      case ChartPeriod.yearly:
        return const [
          SalesChartPoint(label: 'Jan', value: 2100000),
          SalesChartPoint(label: 'Feb', value: 2400000),
          SalesChartPoint(label: 'Mar', value: 1980000),
          SalesChartPoint(label: 'Apr', value: 2650000),
          SalesChartPoint(label: 'May', value: 2890000),
          SalesChartPoint(label: 'Jun', value: 3100000),
        ];
    }
  }

  Future<List<ActivityItem>> getRecentActivity() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    return [
      ActivityItem(
        type: ActivityType.paymentReceived,
        title: 'Payment received',
        subtitle: '₦85,000 from Chidinma Stores',
        timestamp: now.subtract(const Duration(minutes: 25)),
      ),
      ActivityItem(
        type: ActivityType.invoiceCreated,
        title: 'Invoice created',
        subtitle: 'INV-1042 for Kayode Enterprises',
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
      ActivityItem(
        type: ActivityType.shipmentDelivered,
        title: 'Shipment delivered',
        subtitle: 'Order #SO-889 delivered to Ibadan',
        timestamp: now.subtract(const Duration(hours: 5)),
      ),
      ActivityItem(
        type: ActivityType.productAdded,
        title: 'Product added',
        subtitle: '"Dangote Cement 50kg" added to inventory',
        timestamp: now.subtract(const Duration(hours: 8)),
      ),
      ActivityItem(
        type: ActivityType.purchaseOrderReceived,
        title: 'Purchase order received',
        subtitle: 'PO-220 from Lagos Wholesale Ltd',
        timestamp: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  Future<ShipmentOverview> getShipmentOverview() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const ShipmentOverview(
      pending: 6,
      inTransit: 11,
      delivered: 48,
      delayed: 2,
    );
  }

  Future<List<LowStockProduct>> getLowStockProducts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      LowStockProduct(id: '1', name: 'Dangote Cement 50kg', currentQuantity: 8, minimumQuantity: 30),
      LowStockProduct(id: '2', name: 'Paracetamol 500mg (Pack)', currentQuantity: 12, minimumQuantity: 50),
      LowStockProduct(id: '3', name: 'Tecno Spark 10', currentQuantity: 3, minimumQuantity: 15),
      LowStockProduct(id: '4', name: 'NPK Fertilizer 25kg', currentQuantity: 5, minimumQuantity: 20),
    ];
  }

  Future<PerformanceSummary> getPerformanceSummary() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const PerformanceSummary(
      topProducts: [
        TopProduct(name: 'Dangote Cement 50kg', unitsSold: 320, revenue: 1920000),
        TopProduct(name: 'Paracetamol 500mg', unitsSold: 890, revenue: 445000),
        TopProduct(name: 'Tecno Spark 10', unitsSold: 45, revenue: 3150000),
      ],
      topCustomers: [
        TopCustomer(name: 'Chidinma Stores', totalSpent: 1250000, ordersCount: 18),
        TopCustomer(name: 'Kayode Enterprises', totalSpent: 980000, ordersCount: 12),
        TopCustomer(name: 'Lagos Wholesale Ltd', totalSpent: 760000, ordersCount: 9),
      ],
      monthlyProfit: 1840000,
      monthlyExpenses: 620000,
    );
  }
}
