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
      id: JsonUtils.parseInt(json['id']),
      salesOrderId: JsonUtils.parseInt(json['salesOrderId']),
      salesOrder: JsonUtils.parseString(json['salesOrder']),
      productId: JsonUtils.parseInt(json['productId']) ?? 0,
      product: Product.fromJson(JsonUtils.ensureMap(json['product'])),
      quantity: JsonUtils.parseDouble(json['quantity']),
      unitPrice: JsonUtils.parseDouble(json['unitPrice']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'salesOrderId': salesOrderId,
    'salesOrder': salesOrder,
    'productId': productId,
    'product': product.toJson(),
    'quantity': quantity,
    'unitPrice': unitPrice,
  };

  Map<String, dynamic> toCreateJson() => {
    'productId': productId,
    'quantity': quantity,
    'unitPrice': unitPrice,
  };
}
