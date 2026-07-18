import 'package:equatable/equatable.dart';

class SalesChartPoint extends Equatable {
  final String label;
  final double value;

  const SalesChartPoint({required this.label, required this.value});

  @override
  List<Object?> get props => [label, value];
}
