import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/utils/result.dart';
import 'package:traqio/core/config/supabase_config.dart';
import 'package:traqio/features/purchase_orders/data/datasources/purchase_order_remote_datasource.dart';
import 'package:traqio/features/purchase_orders/data/repositories/purchase_order_repository_impl.dart';
import 'package:traqio/features/purchase_orders/domain/entities/po_enums.dart';
import 'package:traqio/features/purchase_orders/domain/entities/purchase_order.dart';
import 'package:traqio/features/purchase_orders/domain/repositories/purchase_order_repository.dart';
import 'package:traqio/features/purchase_orders/domain/usecases/purchase_order_usecases.dart';

final purchaseOrderRemoteDataSourceProvider = Provider<PurchaseOrderRemoteDataSource>((ref) {
  return PurchaseOrderRemoteDataSource(SupabaseConfig.client);
});

final purchaseOrderRepositoryProvider = Provider<PurchaseOrderRepository>((ref) {
  return PurchaseOrderRepositoryImpl(ref.watch(purchaseOrderRemoteDataSourceProvider));
});

final getPurchaseOrdersUseCaseProvider = Provider((ref) {
  return GetPurchaseOrdersUseCase(ref.watch(purchaseOrderRepositoryProvider));
});

final getPurchaseOrderByIdUseCaseProvider = Provider((ref) {
  return GetPurchaseOrderByIdUseCase(ref.watch(purchaseOrderRepositoryProvider));
});

final createPurchaseOrderUseCaseProvider = Provider((ref) {
  return CreatePurchaseOrderUseCase(ref.watch(purchaseOrderRepositoryProvider));
});

final updatePurchaseOrderUseCaseProvider = Provider((ref) {
  return UpdatePurchaseOrderUseCase(ref.watch(purchaseOrderRepositoryProvider));
});

final markPurchaseOrderAsSentUseCaseProvider = Provider((ref) {
  return MarkPurchaseOrderAsSentUseCase(ref.watch(purchaseOrderRepositoryProvider));
});

final cancelPurchaseOrderUseCaseProvider = Provider((ref) {
  return CancelPurchaseOrderUseCase(ref.watch(purchaseOrderRepositoryProvider));
});

final receivePurchaseOrderItemsUseCaseProvider = Provider((ref) {
  return ReceivePurchaseOrderItemsUseCase(ref.watch(purchaseOrderRepositoryProvider));
});

final getPurchaseOrderMetricsUseCaseProvider = Provider((ref) {
  return GetPurchaseOrderMetricsUseCase(ref.watch(purchaseOrderRepositoryProvider));
});

// --- List screen state: filter, search, sort, pagination ---

final poStatusFilterProvider = StateProvider<PurchaseOrderStatus?>((ref) => null);
final poSearchQueryProvider = StateProvider<String>((ref) => '');
final poNewestFirstProvider = StateProvider<bool>((ref) => true);

const poPageSize = 20;

class PurchaseOrderListNotifier extends StateNotifier<AsyncValue<List<PurchaseOrder>>> {
  final Ref ref;
  int _offset = 0;
  bool _hasMore = true;
  bool _isFetchingMore = false;

  PurchaseOrderListNotifier(this.ref) : super(const AsyncValue.loading()) {
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
        _hasMore = orders.length == poPageSize;
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
      (failure) {}, // keep existing list on pagination failure
      (orders) {
        final current = state.valueOrNull ?? [];
        _offset += orders.length;
        _hasMore = orders.length == poPageSize;
        state = AsyncValue.data([...current, ...orders]);
      },
    );
    _isFetchingMore = false;
  }

  Future<Result<List<PurchaseOrder>>> _fetch({required int offset}) {
    final useCase = ref.read(getPurchaseOrdersUseCaseProvider);
    return useCase(
      statusFilter: ref.read(poStatusFilterProvider),
      searchQuery: ref.read(poSearchQueryProvider),
      offset: offset,
      limit: poPageSize,
      newestFirst: ref.read(poNewestFirstProvider),
    );
  }
}

final purchaseOrderListProvider =
    StateNotifierProvider<PurchaseOrderListNotifier, AsyncValue<List<PurchaseOrder>>>((ref) {
  // Re-create the notifier whenever filter/search/sort changes.
  ref.watch(poStatusFilterProvider);
  ref.watch(poSearchQueryProvider);
  ref.watch(poNewestFirstProvider);
  return PurchaseOrderListNotifier(ref);
});

final purchaseOrderDetailProvider =
    FutureProvider.family<PurchaseOrder, String>((ref, id) async {
  final result = await ref.watch(getPurchaseOrderByIdUseCaseProvider)(id);
  return result.match((failure) => throw failure, (data) => data);
});

final purchaseOrderMetricsProvider = FutureProvider((ref) async {
  final result = await ref.watch(getPurchaseOrderMetricsUseCaseProvider)();
  return result.match((failure) => throw failure, (data) => data);
});
