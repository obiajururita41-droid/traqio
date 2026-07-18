import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/dashboard/domain/entities/activity_item.dart';
import 'package:traqio/features/dashboard/domain/entities/chart_period.dart';
import 'package:traqio/features/dashboard/domain/entities/dashboard_stat.dart';
import 'package:traqio/features/dashboard/domain/entities/low_stock_product.dart';
import 'package:traqio/features/dashboard/domain/entities/performance_summary.dart';
import 'package:traqio/features/dashboard/domain/entities/sales_chart_point.dart';
import 'package:traqio/features/dashboard/domain/entities/shipment_overview.dart';

/// Contract the Dashboard depends on. The implementation below is a
/// placeholder — once Inventory/Sales/Invoices/Shipment modules exist,
/// only DashboardRepositoryImpl needs to change, never this file or
/// anything in presentation/.
abstract class DashboardRepository {
  Future<Result<DashboardSummary>> getDashboardSummary();
  Future<Result<List<SalesChartPoint>>> getSalesChart(ChartPeriod period);
  Future<Result<List<ActivityItem>>> getRecentActivity();
  Future<Result<ShipmentOverview>> getShipmentOverview();
  Future<Result<List<LowStockProduct>>> getLowStockProducts();
  Future<Result<PerformanceSummary>> getPerformanceSummary();
}
