import '../models/product_model.dart';
import '../utils/json_utils.dart';

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

  factory SalesOrderItem.fromJson(Map<String, dynamic>? json) {
    json = json ?? {};
    return SalesOrderItem(
      id: JsonUtils.parseInt(json['Id']),
      salesOrderId: JsonUtils.parseInt(json['SalesOrderId']),
      salesOrder: JsonUtils.parseString(json['SalesOrder']),
      productId: JsonUtils.parseInt(json['ProductId']) ?? 0,
      product: Product.fromJson(JsonUtils.ensureMap(json['Product'])),
      quantity: JsonUtils.parseDouble(json['Quantity']),
      unitPrice: JsonUtils.parseDouble(json['UnitPrice']),
    );
  }

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
