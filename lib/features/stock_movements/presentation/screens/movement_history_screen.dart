import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/stock_movements/presentation/providers/inventory_providers.dart';
import 'package:traqio/features/stock_movements/presentation/screens/record_movement_screen.dart';
import 'package:traqio/features/stock_movements/presentation/widgets/movement_tile.dart';

class MovementHistoryScreen extends ConsumerWidget {
  const MovementHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final movementsAsync = ref.watch(movementHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Movements')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const RecordMovementScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Record Movement'),
      ),
      body: SafeArea(
        child: movementsAsync.when(
          data: (movements) {
            if (movements.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                    const SizedBox(height: AppSpacing.md),
                    Text('No stock movements yet', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Stock in, stock out, and adjustments will appear here',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(movementHistoryProvider),
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.xl),
                itemCount: movements.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) => MovementTile(movement: movements[index]),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Could not load movements: $e')),
        ),
      ),
    );
  }
}
