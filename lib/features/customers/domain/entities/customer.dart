import 'package:equatable/equatable.dart';
import 'package:traqio/features/customers/domain/entities/customer_enums.dart';

class Customer extends Equatable {
  final String id;
  final String businessId;

  final String name;
  final String? phone;
  final String? email;
  final String? address;

  final CustomerType customerType;
  final double creditLimit;
  final double outstandingBalance;
  final double loyaltyPoints;

  final String? notes;
  final CustomerStatus status;

  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;

  const Customer({
    required this.id,
    required this.businessId,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.customerType = CustomerType.retail,
    this.creditLimit = 0,
    this.outstandingBalance = 0,
    this.loyaltyPoints = 0,
    this.notes,
    this.status = CustomerStatus.active,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
  });

  /// Remaining credit before the customer hits their limit. Sales
  /// Orders / POS can check this before allowing a credit sale.
  double get availableCredit => creditLimit - outstandingBalance;

  bool get isOverCreditLimit => outstandingBalance > creditLimit && creditLimit > 0;
  bool get isActive => status == CustomerStatus.active;

  Customer copyWith({
    String? name,
    String? phone,
    String? email,
    String? address,
    CustomerType? customerType,
    double? creditLimit,
    double? loyaltyPoints,
    String? notes,
    CustomerStatus? status,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id,
      businessId: businessId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      customerType: customerType ?? this.customerType,
      creditLimit: creditLimit ?? this.creditLimit,
      outstandingBalance: outstandingBalance,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy,
    );
  }

  @override
  List<Object?> get props => [
        id, businessId, name, phone, email, address, customerType,
        creditLimit, outstandingBalance, loyaltyPoints, notes, status,
        createdAt, updatedAt, createdBy,
      ];
}
