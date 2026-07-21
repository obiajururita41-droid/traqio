import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/business/current_business_provider.dart';
import 'package:traqio/core/config/supabase_config.dart';
import 'package:traqio/core/utils/result.dart';
import 'package:traqio/features/invoices/data/datasources/invoice_remote_datasource.dart';
import 'package:traqio/features/invoices/data/repositories/invoice_repository_impl.dart';
import 'package:traqio/features/invoices/domain/entities/invoice.dart';
import 'package:traqio/features/invoices/domain/entities/invoice_enums.dart';
import 'package:traqio/features/invoices/domain/repositories/invoice_repository.dart';
import 'package:traqio/features/invoices/domain/usecases/invoice_usecases.dart';

final invoiceRemoteDataSourceProvider = Provider<InvoiceRemoteDataSource>((ref) {
  return InvoiceRemoteDataSource(SupabaseConfig.client, ref.watch(currentBusinessIdProvider));
});

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  return InvoiceRepositoryImpl(ref.watch(invoiceRemoteDataSourceProvider));
});

final getInvoicesUseCaseProvider = Provider((ref) {
  return GetInvoicesUseCase(ref.watch(invoiceRepositoryProvider));
});

final getInvoiceByIdUseCaseProvider = Provider((ref) {
  return GetInvoiceByIdUseCase(ref.watch(invoiceRepositoryProvider));
});

final generateInvoiceFromSalesOrderUseCaseProvider = Provider((ref) {
  return GenerateInvoiceFromSalesOrderUseCase(ref.watch(invoiceRepositoryProvider));
});

final markInvoiceAsSentUseCaseProvider = Provider((ref) {
  return MarkInvoiceAsSentUseCase(ref.watch(invoiceRepositoryProvider));
});

final cancelInvoiceUseCaseProvider = Provider((ref) {
  return CancelInvoiceUseCase(ref.watch(invoiceRepositoryProvider));
});

final recordInvoicePaymentUseCaseProvider = Provider((ref) {
  return RecordInvoicePaymentUseCase(ref.watch(invoiceRepositoryProvider));
});

final getInvoicePaymentsUseCaseProvider = Provider((ref) {
  return GetInvoicePaymentsUseCase(ref.watch(invoiceRepositoryProvider));
});

final getInvoiceMetricsUseCaseProvider = Provider((ref) {
  return GetInvoiceMetricsUseCase(ref.watch(invoiceRepositoryProvider));
});

final invoiceStatusFilterProvider = StateProvider<InvoiceStatus?>((ref) => null);
final invoiceSearchQueryProvider = StateProvider<String>((ref) => '');
final invoiceNewestFirstProvider = StateProvider<bool>((ref) => true);

const invoicePageSize = 20;

class InvoiceListNotifier extends StateNotifier<AsyncValue<List<Invoice>>> {
  final Ref ref;
  int _offset = 0;
  bool _hasMore = true;
  bool _isFetchingMore = false;

  InvoiceListNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    state = const AsyncValue.loading();
    _offset = 0;
    _hasMore = true;
    final result = await _fetch(offset: 0);
    result.match(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (invoices) {
        _offset = invoices.length;
        _hasMore = invoices.length == invoicePageSize;
        state = AsyncValue.data(invoices);
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
      (invoices) {
        final current = state.valueOrNull ?? [];
        _offset += invoices.length;
        _hasMore = invoices.length == invoicePageSize;
        state = AsyncValue.data([...current, ...invoices]);
      },
    );
    _isFetchingMore = false;
  }

  Future<Result<List<Invoice>>> _fetch({required int offset}) {
    final useCase = ref.read(getInvoicesUseCaseProvider);
    return useCase(
      statusFilter: ref.read(invoiceStatusFilterProvider),
      searchQuery: ref.read(invoiceSearchQueryProvider),
      offset: offset,
      limit: invoicePageSize,
      newestFirst: ref.read(invoiceNewestFirstProvider),
    );
  }
}

final invoiceListProvider =
    StateNotifierProvider<InvoiceListNotifier, AsyncValue<List<Invoice>>>((ref) {
  ref.watch(invoiceStatusFilterProvider);
  ref.watch(invoiceSearchQueryProvider);
  ref.watch(invoiceNewestFirstProvider);
  return InvoiceListNotifier(ref);
});

final invoiceDetailProvider = FutureProvider.family<Invoice, String>((ref, id) async {
  final result = await ref.watch(getInvoiceByIdUseCaseProvider)(id);
  return result.match((failure) => throw failure, (data) => data);
});

final invoicePaymentsProvider = FutureProvider.family((ref, String invoiceId) async {
  final result = await ref.watch(getInvoicePaymentsUseCaseProvider)(invoiceId);
  return result.match((failure) => throw failure, (data) => data);
});

final invoiceMetricsProvider = FutureProvider((ref) async {
  final result = await ref.watch(getInvoiceMetricsUseCaseProvider)();
  return result.match((failure) => throw failure, (data) => data);
});
