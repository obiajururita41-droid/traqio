import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/utils/result.dart';
import 'package:traqio/core/config/supabase_config.dart';
import 'package:traqio/features/sales_orders/data/datasources/sales_order_remote_datasource.dart';
import 'package:traqio/features/sales_orders/data/repositories/sales_order_repository_impl.dart';
import 'package:traqio/features/sales_orders/domain/entities/sales_order.dart';
import 'package:traqio/features/sales_orders/domain/entities/so_enums.dart';
import 'package:traqio/features/sales_orders/domain/repositories/sales_order_repository.dart';
import 'package:traqio/features/sales_orders/domain/usecases/sales_order_usecases.dart';

final salesOrderRemoteDataSourceProvider = Provider<SalesOrderRemoteDataSource>((ref) {
  return SalesOrderRemoteDataSource(SupabaseConfig.client);
});

final salesOrderRepositoryProvider = Provider<SalesOrderRepository>((ref) {
  return SalesOrderRepositoryImpl(ref.watch(salesOrderRemoteDataSourceProvider));
});

final getSalesOrdersUseCaseProvider = Provider((ref) {
  return GetSalesOrdersUseCase(ref.watch(salesOrderRepositoryProvider));
});

final getSalesOrderByIdUseCaseProvider = Provider((ref) {
  return GetSalesOrderByIdUseCase(ref.watch(salesOrderRepositoryProvider));
});

final createSalesOrderUseCaseProvider = Provider((ref) {
  return CreateSalesOrderUseCase(ref.watch(salesOrderRepositoryProvider));
});

final updateSalesOrderUseCaseProvider = Provider((ref) {
  return UpdateSalesOrderUseCase(ref.watch(salesOrderRepositoryProvider));
});

final confirmSalesOrderUseCaseProvider = Provider((ref) {
  return ConfirmSalesOrderUseCase(ref.watch(salesOrderRepositoryProvider));
});

final cancelSalesOrderUseCaseProvider = Provider((ref) {
  return CancelSalesOrderUseCase(ref.watch(salesOrderRepositoryProvider));
});

final fulfillSalesOrderItemsUseCaseProvider = Provider((ref) {
  return FulfillSalesOrderItemsUseCase(ref.watch(salesOrderRepositoryProvider));
});

final getSalesOrderMetricsUseCaseProvider = Provider((ref) {
  return GetSalesOrderMetricsUseCase(ref.watch(salesOrderRepositoryProvider));
});

final soStatusFilterProvider = StateProvider<SalesOrderStatus?>((ref) => null);
final soSearchQueryProvider = StateProvider<String>((ref) => '');
final soNewestFirstProvider = StateProvider<bool>((ref) => true);

const soPageSize = 20;

class SalesOrderListNotifier extends StateNotifier<AsyncValue<List<SalesOrder>>> {
  final Ref ref;
  int _offset = 0;
  bool _hasMore = true;
  bool _isFetchingMore = false;

  SalesOrderListNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    state = const AsyncValue.loading();
    _offset = 0;
    _hasMore = true;
    final result = await _fetch(offset: 0);
    result.match(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (orders) {
        _offset = orders.length;
        _hasMore = orders.length == soPageSize;
        state = AsyncValue.data(orders);
      },
    );
  }

  Future<void> refresh() => _loadInitial();

  Future<void> loadMore() async {
    if (_isFetchingMore || !_hasMore) return;
    _isFetchingMore = true;
    final result = await _fetch(offset: _offset);
    result.match(
      (failure) {},
      (orders) {
        final current = state.valueOrNull ?? [];
        _offset += orders.length;
        _hasMore = orders.length == soPageSize;
        state = AsyncValue.data([...current, ...orders]);
      },
    );
    _isFetchingMore = false;
  }

  Future<Result<List<SalesOrder>>> _fetch({required int offset}) {
    final useCase = ref.read(getSalesOrdersUseCaseProvider);
    return useCase(
      statusFilter: ref.read(soStatusFilterProvider),
      searchQuery: ref.read(soSearchQueryProvider),
      offset: offset,
      limit: soPageSize,
      newestFirst: ref.read(soNewestFirstProvider),
    );
  }
}

final salesOrderListProvider =
    StateNotifierProvider<SalesOrderListNotifier, AsyncValue<List<SalesOrder>>>((ref) {
  ref.watch(soStatusFilterProvider);
  ref.watch(soSearchQueryProvider);
  ref.watch(soNewestFirstProvider);
  return SalesOrderListNotifier(ref);
});

final salesOrderDetailProvider =
    FutureProvider.family<SalesOrder, String>((ref, id) async {
  final result = await ref.watch(getSalesOrderByIdUseCaseProvider)(id);
  return result.match((failure) => throw failure, (data) => data);
});

final salesOrderMetricsProvider = FutureProvider((ref) async {
  final result = await ref.watch(getSalesOrderMetricsUseCaseProvider)();
  return result.match((failure) => throw failure, (data) => data);
});
