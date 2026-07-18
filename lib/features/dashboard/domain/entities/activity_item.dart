import 'package:equatable/equatable.dart';

enum ActivityType {
  productAdded,
  invoiceCreated,
  paymentReceived,
  purchaseOrderReceived,
  shipmentDelivered,
}

class ActivityItem extends Equatable {
  final ActivityType type;
  final String title;
  final String subtitle;
  final DateTime timestamp;

  const ActivityItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [type, title, subtitle, timestamp];
}
