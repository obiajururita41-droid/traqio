import 'package:equatable/equatable.dart';

class PaymentMetrics extends Equatable {
  final double totalReceivedThisMonth;
  final double totalPaidOutThisMonth;
  final int paymentsCountThisMonth;

  const PaymentMetrics({
    required this.totalReceivedThisMonth,
    required this.totalPaidOutThisMonth,
    required this.paymentsCountThisMonth,
  });

  @override
  List<Object?> get props =>
      [totalReceivedThisMonth, totalPaidOutThisMonth, paymentsCountThisMonth];
}
