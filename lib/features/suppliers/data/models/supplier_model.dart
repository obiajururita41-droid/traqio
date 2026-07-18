import 'package:traqio/features/suppliers/domain/entities/supplier.dart';
import 'package:traqio/features/suppliers/domain/entities/supplier_enums.dart';

class SupplierModel extends Supplier {
  const SupplierModel({
    required super.id,
    required super.businessId,
    required super.name,
    super.contactPerson,
    super.phone,
    super.email,
    super.address,
    super.supplierType,
    super.paymentTerms,
    super.outstandingBalance,
    super.notes,
    super.status,
    required super.createdAt,
    required super.updatedAt,
    super.createdBy,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      name: json['name'] as String,
      contactPerson: json['contact_person'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      supplierType: SupplierTypeX.fromDb(json['supplier_type'] as String? ?? 'local'),
      paymentTerms: json['payment_terms'] as String?,
      outstandingBalance: (json['outstanding_balance'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String?,
      status: SupplierStatusX.fromDb(json['status'] as String? ?? 'active'),
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
      'contact_person': contactPerson,
      'phone': phone,
      'email': email,
      'address': address,
      'supplier_type': supplierType.dbValue,
      'payment_terms': paymentTerms,
      'notes': notes,
      'status': status.dbValue,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'created_by': createdBy,
    };
  }

  factory SupplierModel.fromEntity(Supplier supplier) {
    return SupplierModel(
      id: supplier.id,
      businessId: supplier.businessId,
      name: supplier.name,
      contactPerson: supplier.contactPerson,
      phone: supplier.phone,
      email: supplier.email,
      address: supplier.address,
      supplierType: supplier.supplierType,
      paymentTerms: supplier.paymentTerms,
      outstandingBalance: supplier.outstandingBalance,
      notes: supplier.notes,
      status: supplier.status,
      createdAt: supplier.createdAt,
      updatedAt: supplier.updatedAt,
      createdBy: supplier.createdBy,
    );
  }
}
