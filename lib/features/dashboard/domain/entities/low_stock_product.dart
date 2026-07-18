import 'package:equatable/equatable.dart';

class LowStockProduct extends Equatable {
  final String id;
  final String name;
  final int currentQuantity;
  final int minimumQuantity;

  const LowStockProduct({
    required this.id,
    required this.name,
    required this.currentQuantity,
    required this.minimumQuantity,
  });

  @override
  List<Object?> get props => [id, name, currentQuantity, minimumQuantity];
}
