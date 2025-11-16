import '../models/product_model.dart';
import '../utils/json_utils.dart';

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

  factory PurchaseOrderItem.fromJson(Map<String, dynamic>? json) {
    json = json ?? {};

    return PurchaseOrderItem(
      id: JsonUtils.parseInt(json['Id']),
      purchaseOrderId: JsonUtils.parseInt(json['PurchaseOrderId']),
      purchaseOrder: JsonUtils.parseString(json['PurchaseOrder']),
      productId: JsonUtils.parseInt(json['ProductId']) ?? 0,
      product: Product.fromJson(JsonUtils.ensureMap(json['Product'])),
      quantity: JsonUtils.parseDouble(json['Quantity']),
      unitPrice: JsonUtils.parseDouble(json['UnitPrice']),
    );
  }

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
