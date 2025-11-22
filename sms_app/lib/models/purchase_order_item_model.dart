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
      id: JsonUtils.parseInt(json['id']),
      purchaseOrderId: JsonUtils.parseInt(json['purchaseOrderId']),
      purchaseOrder: JsonUtils.parseString(json['purchaseOrder']),
      productId: JsonUtils.parseInt(json['productId']) ?? 0,
      product: Product.fromJson(JsonUtils.ensureMap(json['product'])),
      quantity: JsonUtils.parseDouble(json['quantity']),
      unitPrice: JsonUtils.parseDouble(json['unitPrice']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'purchaseOrderId': purchaseOrderId,
    'purchaseOrder': purchaseOrder,
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
