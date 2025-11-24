import '../models/purchase_order_item_model.dart';
import '../utils/json_utils.dart';
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

  factory PurchaseOrder.fromJson(Map<String, dynamic>? json) {
    json = json ?? {};
    return PurchaseOrder(
      id: JsonUtils.parseInt(json['Id']),
      transNumber: JsonUtils.parseString(json['transNumber']),
      transDate: _parseDate(json['transDate']),
      supplierId: JsonUtils.parseInt(json['supplierId']) ?? 0,
      supplier: Supplier.fromJson(JsonUtils.ensureMap(json['supplier'])),
      grandTotal: JsonUtils.parseDouble(json['grandTotal']),
      items: _parseItems(json['items']),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;

    final s = JsonUtils.parseString(value);
    return DateTime.tryParse(s) ?? DateTime.now();
  }

  static List<PurchaseOrderItem> _parseItems(dynamic value) {
    if (value is List) {
      return value
          .map((e) => PurchaseOrderItem.fromJson(JsonUtils.ensureMap(e)))
          .toList();
    }
    return <PurchaseOrderItem>[];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'transNumber': transNumber,
    'transDate': transDate.toIso8601String(),
    'supplierId': supplierId,
    'supplier': supplier.toJson(),
    'grandTotal': grandTotal,
    'items': items.map((i) => i.toJson()).toList(),
  };

  Map<String, dynamic> toCreateJson() => {
    'transNumber': transNumber,
    'transDate': transDate.toIso8601String(),
    'supplierId': supplierId,
    'grandTotal': grandTotal,
    'items': items.map((i) => i.toCreateJson()).toList(),
  };

  Map<String, dynamic> toUpdateJson() => {
    'id': id,
    'transNumber': transNumber,
    'transDate': transDate.toIso8601String(),
    'supplierId': supplierId,
    'grandTotal': grandTotal,
    'items': items.map((i) => i.toCreateJson()).toList(),
  };

}

