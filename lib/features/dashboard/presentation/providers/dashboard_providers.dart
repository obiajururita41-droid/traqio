import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/config/supabase_config.dart';
import 'package:traqio/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:traqio/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:traqio/features/dashboard/domain/entities/chart_period.dart';
import 'package:traqio/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:traqio/features/dashboard/domain/usecases/dashboard_usecases.dart';

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((ref) {
  return DashboardRemoteDataSource(SupabaseConfig.client);
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(ref.watch(dashboardRemoteDataSourceProvider));
});

final getDashboardSummaryUseCaseProvider = Provider((ref) {
  return GetDashboardSummaryUseCase(ref.watch(dashboardRepositoryProvider));
});

final getSalesChartUseCaseProvider = Provider((ref) {
  return GetSalesChartUseCase(ref.watch(dashboardRepositoryProvider));
});

final getRecentActivityUseCaseProvider = Provider((ref) {
  return GetRecentActivityUseCase(ref.watch(dashboardRepositoryProvider));
});

final getShipmentOverviewUseCaseProvider = Provider((ref) {
  return GetShipmentOverviewUseCase(ref.watch(dashboardRepositoryProvider));
});

final getLowStockProductsUseCaseProvider = Provider((ref) {
  return GetLowStockProductsUseCase(ref.watch(dashboardRepositoryProvider));
});

final getPerformanceSummaryUseCaseProvider = Provider((ref) {
  return GetPerformanceSummaryUseCase(ref.watch(dashboardRepositoryProvider));
});

/// Selected period for the sales chart (Weekly / Monthly / Yearly).
final chartPeriodProvider = StateProvider<ChartPeriod>((ref) => ChartPeriod.weekly);

final dashboardSummaryProvider = FutureProvider((ref) async {
  final result = await ref.watch(getDashboardSummaryUseCaseProvider)();
  return result.match((failure) => throw failure, (data) => data);
});

final salesChartProvider = FutureProvider((ref) async {
  final period = ref.watch(chartPeriodProvider);
  final result = await ref.watch(getSalesChartUseCaseProvider)(period);
  return result.match((failure) => throw failure, (data) => data);
});

final recentActivityProvider = FutureProvider((ref) async {
  final result = await ref.watch(getRecentActivityUseCaseProvider)();
  return result.match((failure) => throw failure, (data) => data);
});

final shipmentOverviewProvider = FutureProvider((ref) async {
  final result = await ref.watch(getShipmentOverviewUseCaseProvider)();
  return result.match((failure) => throw failure, (data) => data);
});

final lowStockProductsProvider = FutureProvider((ref) async {
  final result = await ref.watch(getLowStockProductsUseCaseProvider)();
  return result.match((failure) => throw failure, (data) => data);
});

final performanceSummaryProvider = FutureProvider((ref) async {
  final result = await ref.watch(getPerformanceSummaryUseCaseProvider)();
  return result.match((failure) => throw failure, (data) => data);
});
