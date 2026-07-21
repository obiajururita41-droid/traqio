import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:traqio/core/errors/exceptions.dart';
import 'package:traqio/features/sales_orders/data/models/sales_order_model.dart';
import 'package:traqio/features/sales_orders/domain/entities/sales_order_inputs.dart';
import 'package:traqio/features/sales_orders/domain/entities/so_enums.dart';

class SalesOrderRemoteDataSource {
  final SupabaseClient client;
  final String businessId;
  const SalesOrderRemoteDataSource(this.client, this.businessId);

  static const _table = 'sales_orders';
  static const _selectWithJoins =
      '*, customers(name), sales_order_items(*, products(name))';


  Future<List<SalesOrderModel>> getSalesOrders({
    SalesOrderStatus? statusFilter,
    String? searchQuery,
    required int offset,
    required int limit,
    required bool newestFirst,
  }) async {
    try {
      var query = client
          .from(_table)
          .select(_selectWithJoins)
          .eq('business_id', businessId);

      if (statusFilter != null) {
        query = query.eq('status', statusFilter.dbValue);
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        query = query.ilike('so_number', '%${searchQuery.trim()}%');
      }

      final rows = await query
          .order('order_date', ascending: !newestFirst)
          .range(offset, offset + limit - 1);

      return (rows as List)
          .map((row) => SalesOrderModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<SalesOrderModel> getSalesOrderById(String id) async {
    try {
      final row = await client
          .from(_table)
          .select(_selectWithJoins)
          .eq('id', id)
          .eq('business_id', businessId)
          .single();
      return SalesOrderModel.fromJson(row);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Map<String, dynamic> _itemToJson(SalesOrderItemInput item) => {
        'product_id': item.productId,
        'quantity_ordered': item.quantityOrdered,
        'unit_price': item.unitPrice,
        'tax_rate': item.taxRate,
      };

  Future<SalesOrderModel> createSalesOrder({
    required String customerId,
    required String soNumber,
    required DateTime orderDate,
    DateTime? expectedDeliveryDate,
    String? notes,
    required List<SalesOrderItemInput> items,
  }) async {
    try {
      final row = await client.rpc('create_sales_order', params: {
        'p_business_id': businessId,
        'p_customer_id': customerId,
        'p_so_number': soNumber,
        'p_order_date': orderDate.toIso8601String(),
        'p_expected_delivery_date': expectedDeliveryDate?.toIso8601String(),
        'p_notes': notes,
        'p_items': items.map(_itemToJson).toList(),
      });
      final id = (row as Map<String, dynamic>)['id'] as String;
      return getSalesOrderById(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<SalesOrderModel> updateSalesOrder({
    required String id,
    required String customerId,
    required DateTime orderDate,
    DateTime? expectedDeliveryDate,
    String? notes,
    required List<SalesOrderItemInput> items,
  }) async {
    try {
      await client.rpc('update_sales_order_draft', params: {
        'p_business_id': businessId,
        'p_so_id': id,
        'p_customer_id': customerId,
        'p_order_date': orderDate.toIso8601String(),
        'p_expected_delivery_date': expectedDeliveryDate?.toIso8601String(),
        'p_notes': notes,
        'p_items': items.map(_itemToJson).toList(),
      });
      return getSalesOrderById(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<SalesOrderModel> confirmSalesOrder(String id) async {
    try {
      await client.rpc('confirm_sales_order', params: {'p_business_id': businessId, 'p_so_id': id});
      return getSalesOrderById(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<SalesOrderModel> cancelSalesOrder(String id) async {
    try {
      await client.rpc('cancel_sales_order', params: {'p_business_id': businessId, 'p_so_id': id});
      return getSalesOrderById(id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<SalesOrderModel> fulfillItems({
    required String soId,
    required List<FulfillmentInput> fulfillments,
  }) async {
    try {
      await client.rpc('fulfill_sales_order_items', params: {
        'p_business_id': businessId,
        'p_so_id': soId,
        'p_fulfillments': fulfillments
            .map((f) => {
                  'item_id': f.itemId,
                  'quantity_to_fulfill': f.quantityToFulfill,
                })
            .toList(),
      });
      return getSalesOrderById(soId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<Map<String, dynamic>> getMetricsRaw() async {
    try {
      final rows = await client
          .from(_table)
          .select('status, expected_delivery_date, total_amount')
          .eq('business_id', businessId)
          .not('status', 'in', '(fulfilled,cancelled)');

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
