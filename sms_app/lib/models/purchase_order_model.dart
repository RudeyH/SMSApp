import '../models/purchase_order_item_model.dart';
import 'supplier_model.dart';

class PurchaseOrder {
  int? id;
  final String transNumber;
  final DateTime transDate;
  final int supplierId;
  final Supplier supplier;
  final double grandTotal;
  final List<PurchaseOrderItem> items;

  PurchaseOrder({
    this.id,
    required this.transNumber,
    required this.transDate,
    required this.supplierId,
    required this.supplier,
    required this.grandTotal,
    required this.items,
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) => PurchaseOrder(
    id: json['Id'],
    transNumber: json['TransNumber'],
    transDate: DateTime.parse(json['TransDate']),
    supplierId: json['SupplierId'],
    supplier: Supplier.fromJson(json['Supplier']),
    grandTotal: json['GrandTotal'],
    items: (json['Items'] as List)
        .map((i) => PurchaseOrderItem.fromJson(i))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'Id': id,
    'TransNumber': transNumber,
    'TransDate': transDate.toIso8601String(),
    'SupplierId': supplierId,
    'Supplier': supplier.toJson(),
    'GrandTotal': grandTotal,
    'Items': items.map((i) => i.toJson()).toList(),
  };

  Map<String, dynamic> toCreateJson() => {
    'TransNumber': transNumber,
    'TransDate': transDate.toIso8601String(),
    'SupplierId': supplierId,
    'GrandTotal': grandTotal,
    'Items': items.map((i) => i.toCreateJson()).toList(),
  };

  Map<String, dynamic> toUpdateJson() => {
    'Id': id,
    'TransNumber': transNumber,
    'TransDate': transDate.toIso8601String(),
    'SupplierId': supplierId,
    'GrandTotal': grandTotal,
    'Items': items.map((i) => i.toCreateJson()).toList(),
  };

}

