import '../models/product_model.dart';

class PurchaseOrderItem {
  int? id;
  int? purchaseOrderId;
  final String? purchaseOrder;
  final int productId;
  final Product product;
  final double quantity;
  final double unitPrice;

  PurchaseOrderItem({
    this.id,
    this.purchaseOrderId,
    this.purchaseOrder,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.unitPrice,
  });

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) => PurchaseOrderItem(
    id: json['Id'],
    purchaseOrderId: json['PurchaseOrderId'],
    productId: json['ProductId'],
    product: Product.fromJson(json['Product']),
    quantity: (json['Quantity'] as num).toDouble(),
    unitPrice: (json['UnitPrice'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'Id': id,
    'PurchaseOrderId': purchaseOrderId,
    'PurchaseOrder': purchaseOrder,
    'ProductId': productId,
    'Product': product.toJson(),
    'Quantity': quantity,
    'UnitPrice': unitPrice,
  };

  Map<String, dynamic> toCreateJson() => {
    'ProductId': productId,
    'Quantity': quantity,
    'UnitPrice': unitPrice,
  };
}
