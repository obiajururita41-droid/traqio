import 'package:equatable/equatable.dart';

class ShipmentOverview extends Equatable {
  final int pending;
  final int inTransit;
  final int delivered;
  final int delayed;

  const ShipmentOverview({
    required this.pending,
    required this.inTransit,
    required this.delivered,
    required this.delayed,
  });

  @override
  List<Object?> get props => [pending, inTransit, delivered, delayed];
}
