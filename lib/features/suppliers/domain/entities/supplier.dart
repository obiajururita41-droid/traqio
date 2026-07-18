import 'package:equatable/equatable.dart';
import 'package:traqio/features/suppliers/domain/entities/supplier_enums.dart';

class Supplier extends Equatable {
  final String id;
  final String businessId;

  final String name;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? address;

  final SupplierType supplierType;
  final String? paymentTerms;
  final double outstandingBalance;

  final String? notes;
  final SupplierStatus status;

  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;

  const Supplier({
    required this.id,
    required this.businessId,
    required this.name,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    this.supplierType = SupplierType.local,
    this.paymentTerms,
    this.outstandingBalance = 0,
    this.notes,
    this.status = SupplierStatus.active,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
  });

  bool get isActive => status == SupplierStatus.active;

  Supplier copyWith({
    String? name,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    SupplierType? supplierType,
    String? paymentTerms,
    String? notes,
    SupplierStatus? status,
    DateTime? updatedAt,
  }) {
    return Supplier(
      id: id,
      businessId: businessId,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      supplierType: supplierType ?? this.supplierType,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      outstandingBalance: outstandingBalance,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy,
    );
  }

  @override
  List<Object?> get props => [
        id, businessId, name, contactPerson, phone, email, address,
        supplierType, paymentTerms, outstandingBalance, notes, status,
        createdAt, updatedAt, createdBy,
      ];
}
