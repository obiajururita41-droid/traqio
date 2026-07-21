import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/business/current_business_provider.dart';
import 'package:traqio/core/config/supabase_config.dart';
import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/payments/data/datasources/payment_remote_datasource.dart';
import 'package:traqio/features/payments/data/repositories/payment_repository_impl.dart';
import 'package:traqio/features/payments/domain/entities/payment.dart';
import 'package:traqio/features/payments/domain/entities/payment_enums.dart';
import 'package:traqio/features/payments/domain/repositories/payment_repository.dart';
import 'package:traqio/features/payments/domain/usecases/payment_usecases.dart';

final paymentRemoteDataSourceProvider = Provider<PaymentRemoteDataSource>((ref) {
  return PaymentRemoteDataSource(SupabaseConfig.client, ref.watch(currentBusinessIdProvider));
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryImpl(ref.watch(paymentRemoteDataSourceProvider));
});

final getPaymentsUseCaseProvider = Provider((ref) {
  return GetPaymentsUseCase(ref.watch(paymentRepositoryProvider));
});

final getPaymentByIdUseCaseProvider = Provider((ref) {
  return GetPaymentByIdUseCase(ref.watch(paymentRepositoryProvider));
});

final recordCustomerPaymentUseCaseProvider = Provider((ref) {
  return RecordCustomerPaymentUseCase(ref.watch(paymentRepositoryProvider));
});

final recordSupplierPaymentUseCaseProvider = Provider((ref) {
  return RecordSupplierPaymentUseCase(ref.watch(paymentRepositoryProvider));
});

final getPaymentMetricsUseCaseProvider = Provider((ref) {
  return GetPaymentMetricsUseCase(ref.watch(paymentRepositoryProvider));
});

final paymentTypeFilterProvider = StateProvider<PaymentType?>((ref) => null);
final paymentSearchQueryProvider = StateProvider<String>((ref) => '');
final paymentNewestFirstProvider = StateProvider<bool>((ref) => true);

const paymentPageSize = 20;

class PaymentListNotifier extends StateNotifier<AsyncValue<List<Payment>>> {
  final Ref ref;
  int _offset = 0;
  bool _hasMore = true;
  bool _isFetchingMore = false;

  PaymentListNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    state = const AsyncValue.loading();
    _offset = 0;
    _hasMore = true;
    final result = await _fetch(offset: 0);
    result.match(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (payments) {
        _offset = payments.length;
        _hasMore = payments.length == paymentPageSize;
        state = AsyncValue.data(payments);
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
      (payments) {
        final current = state.valueOrNull ?? [];
        _offset += payments.length;
        _hasMore = payments.length == paymentPageSize;
        state = AsyncValue.data([...current, ...payments]);
      },
    );
    _isFetchingMore = false;
  }

  Future<Result<List<Payment>>> _fetch({required int offset}) {
    final useCase = ref.read(getPaymentsUseCaseProvider);
    return useCase(
      typeFilter: ref.read(paymentTypeFilterProvider),
      searchQuery: ref.read(paymentSearchQueryProvider),
      offset: offset,
      limit: paymentPageSize,
      newestFirst: ref.read(paymentNewestFirstProvider),
    );
  }
}

final paymentListProvider =
    StateNotifierProvider<PaymentListNotifier, AsyncValue<List<Payment>>>((ref) {
  ref.watch(paymentTypeFilterProvider);
  ref.watch(paymentSearchQueryProvider);
  ref.watch(paymentNewestFirstProvider);
  return PaymentListNotifier(ref);
});

final paymentDetailProvider = FutureProvider.family<Payment, String>((ref, id) async {
  final result = await ref.watch(getPaymentByIdUseCaseProvider)(id);
  return result.match((failure) => throw failure, (data) => data);
});

final paymentMetricsProvider = FutureProvider((ref) async {
  final result = await ref.watch(getPaymentMetricsUseCaseProvider)();
  return result.match((failure) => throw failure, (data) => data);
});
