import 'package:traqio/features/customers/domain/entities/customer.dart';
import 'package:traqio/features/customers/domain/entities/customer_enums.dart';

class CustomerModel extends Customer {
  const CustomerModel({
    required super.id,
    required super.businessId,
    required super.name,
    super.phone,
    super.email,
    super.address,
    super.customerType,
    super.creditLimit,
    super.outstandingBalance,
    super.loyaltyPoints,
    super.notes,
    super.status,
    required super.createdAt,
    required super.updatedAt,
    super.createdBy,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      customerType: CustomerTypeX.fromDb(json['customer_type'] as String? ?? 'retail'),
      creditLimit: (json['credit_limit'] as num?)?.toDouble() ?? 0,
      outstandingBalance: (json['outstanding_balance'] as num?)?.toDouble() ?? 0,
      loyaltyPoints: (json['loyalty_points'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String?,
      status: CustomerStatusX.fromDb(json['status'] as String? ?? 'active'),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      createdBy: json['created_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'customer_type': customerType.dbValue,
      'credit_limit': creditLimit,
      'loyalty_points': loyaltyPoints,
      'notes': notes,
      'status': status.dbValue,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'created_by': createdBy,
    };
  }

  factory CustomerModel.fromEntity(Customer customer) {
    return CustomerModel(
      id: customer.id,
      businessId: customer.businessId,
      name: customer.name,
      phone: customer.phone,
      email: customer.email,
      address: customer.address,
      customerType: customer.customerType,
      creditLimit: customer.creditLimit,
      outstandingBalance: customer.outstandingBalance,
      loyaltyPoints: customer.loyaltyPoints,
      notes: customer.notes,
      status: customer.status,
      createdAt: customer.createdAt,
      updatedAt: customer.updatedAt,
      createdBy: customer.createdBy,
    );
  }
}
