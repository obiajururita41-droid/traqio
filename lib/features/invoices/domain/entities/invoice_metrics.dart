import 'package:equatable/equatable.dart';

class InvoiceMetrics extends Equatable {
  final int outstandingCount;
  final double outstandingValue;
  final int overdueCount;

  const InvoiceMetrics({
    required this.outstandingCount,
    required this.outstandingValue,
    required this.overdueCount,
  });

  @override
  List<Object?> get props => [outstandingCount, outstandingValue, overdueCount];
}
