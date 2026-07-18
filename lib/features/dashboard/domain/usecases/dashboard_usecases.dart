import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/dashboard/domain/entities/activity_item.dart';
import 'package:traqio/features/dashboard/domain/entities/chart_period.dart';
import 'package:traqio/features/dashboard/domain/entities/dashboard_stat.dart';
import 'package:traqio/features/dashboard/domain/entities/low_stock_product.dart';
import 'package:traqio/features/dashboard/domain/entities/performance_summary.dart';
import 'package:traqio/features/dashboard/domain/entities/sales_chart_point.dart';
import 'package:traqio/features/dashboard/domain/entities/shipment_overview.dart';
import 'package:traqio/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetDashboardSummaryUseCase {
  final DashboardRepository repository;
  const GetDashboardSummaryUseCase(this.repository);
  Future<Result<DashboardSummary>> call() => repository.getDashboardSummary();
}

class GetSalesChartUseCase {
  final DashboardRepository repository;
  const GetSalesChartUseCase(this.repository);
  Future<Result<List<SalesChartPoint>>> call(ChartPeriod period) =>
      repository.getSalesChart(period);
}

class GetRecentActivityUseCase {
  final DashboardRepository repository;
  const GetRecentActivityUseCase(this.repository);
  Future<Result<List<ActivityItem>>> call() => repository.getRecentActivity();
}

class GetShipmentOverviewUseCase {
  final DashboardRepository repository;
  const GetShipmentOverviewUseCase(this.repository);
  Future<Result<ShipmentOverview>> call() => repository.getShipmentOverview();
}

class GetLowStockProductsUseCase {
  final DashboardRepository repository;
  const GetLowStockProductsUseCase(this.repository);
  Future<Result<List<LowStockProduct>>> call() =>
      repository.getLowStockProducts();
}

class GetPerformanceSummaryUseCase {
  final DashboardRepository repository;
  const GetPerformanceSummaryUseCase(this.repository);
  Future<Result<PerformanceSummary>> call() =>
      repository.getPerformanceSummary();
}
