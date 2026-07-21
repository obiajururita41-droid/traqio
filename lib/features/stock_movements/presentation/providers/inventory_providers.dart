import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/business/current_business_provider.dart';
import 'package:traqio/core/config/supabase_config.dart';
import 'package:traqio/features/products/presentation/providers/product_providers.dart';
import 'package:traqio/features/stock_movements/data/datasources/inventory_remote_datasource.dart';
import 'package:traqio/features/stock_movements/data/repositories/inventory_repository_impl.dart';
import 'package:traqio/features/stock_movements/domain/entities/movement_type.dart';
import 'package:traqio/features/stock_movements/domain/repositories/inventory_repository.dart';
import 'package:traqio/features/stock_movements/domain/usecases/inventory_usecases.dart';

final inventoryRemoteDataSourceProvider = Provider<InventoryRemoteDataSource>((ref) {
  return InventoryRemoteDataSource(SupabaseConfig.client, ref.watch(currentBusinessIdProvider));
});

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepositoryImpl(ref.watch(inventoryRemoteDataSourceProvider));
});

final recordMovementUseCaseProvider = Provider((ref) {
  return RecordMovementUseCase(ref.watch(inventoryRepositoryProvider));
});

final getMovementHistoryUseCaseProvider = Provider((ref) {
  return GetMovementHistoryUseCase(ref.watch(inventoryRepositoryProvider));
});

final getMovementsByReferenceUseCaseProvider = Provider((ref) {
  return GetMovementsByReferenceUseCase(ref.watch(inventoryRepositoryProvider));
});

final getStockValuationUseCaseProvider = Provider((ref) {
  return GetStockValuationUseCase(ref.watch(inventoryRepositoryProvider));
});

/// All movements across every product — the main Inventory history screen.
final movementHistoryProvider = FutureProvider((ref) async {
  final result = await ref.watch(getMovementHistoryUseCaseProvider)();
  return result.match((failure) => throw failure, (data) => data);
});

/// Movements scoped to a single product — used on the product detail view.
final productMovementHistoryProvider =
    FutureProvider.family((ref, String productId) async {
  final result = await ref.watch(getMovementHistoryUseCaseProvider)(productId: productId);
  return result.match((failure) => throw failure, (data) => data);
});

/// Real stock valuation — replaces the Dashboard's placeholder numbers.
final stockValuationProvider = FutureProvider((ref) async {
  final result = await ref.watch(getStockValuationUseCaseProvider)();
  return result.match((failure) => throw failure, (data) => data);
});

/// Controller for the manual "Add Stock" / "Adjust Stock" workflow.
sealed class MovementFormState {
  const MovementFormState();
}

class MovementFormInitial extends MovementFormState {
  const MovementFormInitial();
}

class MovementFormLoading extends MovementFormState {
  const MovementFormLoading();
}

class MovementFormSuccess extends MovementFormState {
  const MovementFormSuccess();
}

class MovementFormError extends MovementFormState {
  final String message;
  const MovementFormError(this.message);
}

class MovementFormController extends StateNotifier<MovementFormState> {
  final Ref ref;
  MovementFormController(this.ref) : super(const MovementFormInitial());

  Future<void> submit({
    required String productId,
    required MovementType movementType,
    required MovementDirection direction,
    required double quantity,
    double? unitCost,
    AdjustmentReason? reasonCode,
    String? batchNumber,
    DateTime? expiryDate,
    String? notes,
  }) async {
    state = const MovementFormLoading();
    final useCase = ref.read(recordMovementUseCaseProvider);
    final result = await useCase(
      productId: productId,
      movementType: movementType,
      direction: direction,
      quantity: quantity,
      unitCost: unitCost,
      reasonCode: reasonCode,
      referenceType: ReferenceType.manual,
      batchNumber: batchNumber,
      expiryDate: expiryDate,
      notes: notes,
    );

    result.match(
      (failure) => state = MovementFormError(failure.message),
      (_) {
        state = const MovementFormSuccess();
        ref.invalidate(movementHistoryProvider);
        ref.invalidate(stockValuationProvider);
        ref.invalidate(productsProvider);
      },
    );
  }

  void reset() => state = const MovementFormInitial();
}

final movementFormControllerProvider =
    StateNotifierProvider<MovementFormController, MovementFormState>((ref) {
  return MovementFormController(ref);
});
