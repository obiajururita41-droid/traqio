import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:traqio/core/errors/exceptions.dart';
import 'package:traqio/features/purchase_orders/data/models/purchase_order_model.dart';
import 'package:traqio/features/purchase_orders/domain/entities/po_enums.dart';
import 'package:traqio/features/purchase_orders/domain/entities/purchase_order_inputs.dart';

class PurchaseOrderRemoteDataSource {
  final SupabaseClient client;
  const PurchaseOrderRemoteDataSource(this.client);

  static const _table = 'purchase_orders';
  static const _selectWithJoins =
      '*, suppliers(name), purchase_order_items(*, products(name))';

  String get _businessId {
    final id = client.auth.currentUser?.id;
    if (id == null) throw ServerException('No authenticated user.');
    return id;
  }

  Future<List<PurchaseOrderModel>> getPurchaseOrders({
    PurchaseOrderStatus? statusFilter,
    String? searchQuery,
    required int offset,
    required int limit,
    required bool newestFirst,
  }) async {
    try {
      var query = client
          .from(_table)
          .select(_selectWithJoins)
          .eq('business_id', _businessId);

      if (statusFilter != null) {
        query = query.eq('status', statusFilter.dbValue);
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        query = query.ilike('po_number', '%${searchQuery.trim()}%');
      }

      final rows = await query
          .order('order_date', ascending: !newestFirst)
          .range(offset, offset + limit - 1);

      return (rows as List)
          .map((row) => PurchaseOrderModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<PurchaseOrderModel> getPurchaseOrderById(String id) async {
    try {
      final row = await client
          .from(_table)
          .select(_selectWithJoins)
          .eq('id', id)
          .eq('business_id', _businessId)
          .single();
      return PurchaseOrderModel.fromJson(row);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Map<String, dynamic> _itemToJson(PurchaseOrderItemInput item) => {
        'product_id': item.productId,
        'quantity_ordered': item.quantityOrdered,
        'unit_cost': item.unitCost,
        'tax_rate': item.taxRate,
      };

  Future<PurchaseOrderModel> createPurchaseOrder({
    required String supplierId,
    required String poNumber,
    required DateTime orderDate,
    DateTime? expectedDeliveryDate,
    String? notes,
    required List<PurchaseOrderItemInput> items,
  }) async {
    try {
      final row = await client.rpc('create_purchase_order', params: {
        'p_supplier_id': supplierId,
        'p_po_number': poNumber,
        'p_order_date': orderDate.toIso8601String(),
        'p_expected_delivery_date': expectedDeliveryDate?.toIso8601String(),
        'p_notes': notes,
        'p_items': items.map(_itemToJson).toList(),
      });
      final id = (row as Map<String, dynamic>)['id'] as String;
      return getPurchaseOrderById(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<PurchaseOrderModel> updatePurchaseOrder({
    required String id,
    required String supplierId,
    required DateTime orderDate,
    DateTime? expectedDeliveryDate,
    String? notes,
    required List<PurchaseOrderItemInput> items,
  }) async {
    try {
      await client.rpc('update_purchase_order_draft', params: {
        'p_po_id': id,
        'p_supplier_id': supplierId,
        'p_order_date': orderDate.toIso8601String(),
        'p_expected_delivery_date': expectedDeliveryDate?.toIso8601String(),
        'p_notes': notes,
        'p_items': items.map(_itemToJson).toList(),
      });
      return getPurchaseOrderById(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<PurchaseOrderModel> markAsSent(String id) async {
    try {
      await client
          .from(_table)
          .update({'status': 'sent', 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', id)
          .eq('business_id', _businessId);
      return getPurchaseOrderById(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<PurchaseOrderModel> cancelPurchaseOrder(String id) async {
    try {
      await client.rpc('cancel_purchase_order', params: {'p_po_id': id});
      return getPurchaseOrderById(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<PurchaseOrderModel> receiveItems({
    required String poId,
    required List<ReceiptInput> receipts,
  }) async {
    try {
      await client.rpc('receive_purchase_order_items', params: {
        'p_po_id': poId,
        'p_receipts': receipts
            .map((r) => {
                  'item_id': r.itemId,
                  'quantity_to_receive': r.quantityToReceive,
                })
            .toList(),
      });
      return getPurchaseOrderById(poId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<Map<String, dynamic>> getMetricsRaw() async {
    try {
      final rows = await client
          .from(_table)
          .select('status, expected_delivery_date, total_amount')
          .eq('business_id', _businessId)
          .not('status', 'in', '(received,cancelled)');

      int openCount = 0;
      int overdueCount = 0;
      double pendingValue = 0;
      final now = DateTime.now();

      for (final row in rows as List) {
        openCount++;
        pendingValue += (row['total_amount'] as num?)?.toDouble() ?? 0;
        final expected = row['expected_delivery_date'];
        if (expected != null && DateTime.parse(expected as String).isBefore(now)) {
          overdueCount++;
        }
      }

      return {
        'open_orders_count': openCount,
        'overdue_count': overdueCount,
        'pending_value': pendingValue,
      };
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
