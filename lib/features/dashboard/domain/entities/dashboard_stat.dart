import 'package:equatable/equatable.dart';

class DashboardStat extends Equatable {
  final String title;
  final String value;
  final String description;
  final double percentageChange;
  final bool isPositive;

  const DashboardStat({
    required this.title,
    required this.value,
    required this.description,
    required this.percentageChange,
    required this.isPositive,
  });

  @override
  List<Object?> get props =>
      [title, value, description, percentageChange, isPositive];
}

class DashboardSummary extends Equatable {
  final DashboardStat todaysSales;
  final DashboardStat inventoryValue;
  final DashboardStat lowStockAlerts;
  final DashboardStat outstandingInvoices;

  const DashboardSummary({
    required this.todaysSales,
    required this.inventoryValue,
    required this.lowStockAlerts,
    required this.outstandingInvoices,
  });

  @override
  List<Object?> get props =>
      [todaysSales, inventoryValue, lowStockAlerts, outstandingInvoices];
}
