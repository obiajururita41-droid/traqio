import 'package:equatable/equatable.dart';

/// Generic product entity shared across Inventory, Purchase Orders,
/// Sales Orders, Invoices, POS, and Reporting. Any business type
/// (retail, pharmacy, hardware, wholesale) maps onto this same shape —
/// unit_of_measure and category_id are free-form/relational precisely
/// so no schema change is needed per business type.
class Product extends Equatable {
  // Core
  final String id;
  final String businessId;
  final String name;
  final String? sku;
  final String? barcode;
  final String? description;
  final String? categoryId;
  final String? brand;
  final String unitOfMeasure;
  final String? productImage;
  final bool activeStatus;

  // Pricing
  final double costPrice;
  final double sellingPrice;
  final double? wholesalePrice;
  final double? retailPrice;
  final double? taxRate;
  final double? discountPrice;

  // Inventory
  final double currentStock;
  final double reservedStock;
  final double minimumStock;
  final double reorderLevel;
  final double? maximumStock;
  final double? openingStock;
  final DateTime? openingStockDate;

  // Supplier
  final String? supplierId;
  final String? manufacturer;
  final String? countryOfOrigin;

  // Tracking
  final DateTime? expiryDate;
  final String? batchNumber;
  final String? serialNumber;

  // Accounting
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? lastModifiedBy;

  const Product({
    required this.id,
    required this.businessId,
    required this.name,
    this.sku,
    this.barcode,
    this.description,
    this.categoryId,
    this.brand,
    required this.unitOfMeasure,
    this.productImage,
    this.activeStatus = true,
    required this.costPrice,
    required this.sellingPrice,
    this.wholesalePrice,
    this.retailPrice,
    this.taxRate,
    this.discountPrice,
    this.currentStock = 0,
    this.reservedStock = 0,
    this.minimumStock = 0,
    this.reorderLevel = 0,
    this.maximumStock,
    this.openingStock,
    this.openingStockDate,
    this.supplierId,
    this.manufacturer,
    this.countryOfOrigin,
    this.expiryDate,
    this.batchNumber,
    this.serialNumber,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.lastModifiedBy,
  });

  /// Stock actually available to sell (excludes stock reserved by
  /// pending sales orders). Sales/POS modules should use this, not
  /// currentStock directly.
  double get availableStock => currentStock - reservedStock;

  bool get isLowStock => currentStock <= minimumStock;
  bool get isAtReorderPoint => currentStock <= reorderLevel;

  Product copyWith({
    String? name,
    String? sku,
    String? barcode,
    String? description,
    String? categoryId,
    String? brand,
    String? unitOfMeasure,
    String? productImage,
    bool? activeStatus,
    double? costPrice,
    double? sellingPrice,
    double? wholesalePrice,
    double? retailPrice,
    double? taxRate,
    double? discountPrice,
    double? currentStock,
    double? reservedStock,
    double? minimumStock,
    double? reorderLevel,
    double? maximumStock,
    double? openingStock,
    DateTime? openingStockDate,
    String? supplierId,
    String? manufacturer,
    String? countryOfOrigin,
    DateTime? expiryDate,
    String? batchNumber,
    String? serialNumber,
    DateTime? updatedAt,
    String? lastModifiedBy,
  }) {
    return Product(
      id: id,
      businessId: businessId,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      brand: brand ?? this.brand,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      productImage: productImage ?? this.productImage,
      activeStatus: activeStatus ?? this.activeStatus,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      retailPrice: retailPrice ?? this.retailPrice,
      taxRate: taxRate ?? this.taxRate,
      discountPrice: discountPrice ?? this.discountPrice,
      currentStock: currentStock ?? this.currentStock,
      reservedStock: reservedStock ?? this.reservedStock,
      minimumStock: minimumStock ?? this.minimumStock,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      maximumStock: maximumStock ?? this.maximumStock,
      openingStock: openingStock ?? this.openingStock,
      openingStockDate: openingStockDate ?? this.openingStockDate,
      supplierId: supplierId ?? this.supplierId,
      manufacturer: manufacturer ?? this.manufacturer,
      countryOfOrigin: countryOfOrigin ?? this.countryOfOrigin,
      expiryDate: expiryDate ?? this.expiryDate,
      batchNumber: batchNumber ?? this.batchNumber,
      serialNumber: serialNumber ?? this.serialNumber,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        businessId,
        name,
        sku,
        barcode,
        description,
        categoryId,
        brand,
        unitOfMeasure,
        productImage,
        activeStatus,
        costPrice,
        sellingPrice,
        wholesalePrice,
        retailPrice,
        taxRate,
        discountPrice,
        currentStock,
        reservedStock,
        minimumStock,
        reorderLevel,
        maximumStock,
        openingStock,
        openingStockDate,
        supplierId,
        manufacturer,
        countryOfOrigin,
        expiryDate,
        batchNumber,
        serialNumber,
        createdAt,
        updatedAt,
        createdBy,
        lastModifiedBy,
      ];
}
