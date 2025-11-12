import '../models/product_model.dart';

class SalesOrderItem {
  int? id;
  int? salesOrderId;
  final String? salesOrder;
  final int productId;
  final Product product;
  final double quantity;
  final double unitPrice;

  SalesOrderItem({
    this.id,
    this.salesOrderId,
    this.salesOrder,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.unitPrice,
  });

    factory SalesOrderItem.fromJson(Map<String, dynamic> json) => SalesOrderItem(
    id: json['Id'],
    salesOrderId: json['SalesOrderId'],
    productId: json['ProductId'],
    product: Product.fromJson(json['Product']),
    quantity: (json['Quantity'] as num).toDouble(),
    unitPrice: (json['UnitPrice'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'Id': id,
    'SalesOrderId': salesOrderId,
    'SalesOrder': salesOrder,
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
