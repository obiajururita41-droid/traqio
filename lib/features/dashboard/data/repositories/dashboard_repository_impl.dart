import 'package:traqio/core/errors/failures.dart';
import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:traqio/features/dashboard/domain/entities/activity_item.dart';
import 'package:traqio/features/dashboard/domain/entities/chart_period.dart';
import 'package:traqio/features/dashboard/domain/entities/dashboard_stat.dart';
import 'package:traqio/features/dashboard/domain/entities/low_stock_product.dart';
import 'package:traqio/features/dashboard/domain/entities/performance_summary.dart';
import 'package:traqio/features/dashboard/domain/entities/sales_chart_point.dart';
import 'package:traqio/features/dashboard/domain/entities/shipment_overview.dart';
import 'package:traqio/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  const DashboardRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<DashboardSummary>> getDashboardSummary() async {
    try {
      return Result.right(await remoteDataSource.getDashboardSummary());
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<SalesChartPoint>>> getSalesChart(ChartPeriod period) async {
    try {
      return Result.right(await remoteDataSource.getSalesChart(period));
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<ActivityItem>>> getRecentActivity() async {
    try {
      return Result.right(await remoteDataSource.getRecentActivity());
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<ShipmentOverview>> getShipmentOverview() async {
    try {
      return Result.right(await remoteDataSource.getShipmentOverview());
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<LowStockProduct>>> getLowStockProducts() async {
    try {
      return Result.right(await remoteDataSource.getLowStockProducts());
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<PerformanceSummary>> getPerformanceSummary() async {
    try {
      return Result.right(await remoteDataSource.getPerformanceSummary());
    } catch (e) {
      return Result.left(ServerFailure(e.toString()));
    }
  }
}
