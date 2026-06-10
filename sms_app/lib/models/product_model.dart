import 'package:sms_app/models/uom_model.dart';
import 'package:sms_app/models/product_group_model.dart';

import '../utils/json_utils.dart';

class Product {

  final int? id;

  final String code;
  final String name;

  final double price;
  final double quantity;

  final int uomId;
  UOM uom;

  final int productGroupId;
  ProductGroup? productGroup;

  Product({
    this.id,

    required this.code,
    required this.name,

    required this.price,
    required this.quantity,

    required this.uomId,
    required this.uom,

    required this.productGroupId,
    this.productGroup,
  });

  factory Product.fromJson(
      Map<String, dynamic>? json,
      ) {

    json = json ?? {};

    return Product(

      id: JsonUtils.parseInt(json['id']),

      code: JsonUtils.parseString(json['code']),

      name: JsonUtils.parseString(json['name']),

      price: JsonUtils.parseDouble(json['price']),

      quantity: JsonUtils.parseDouble(json['quantity']),

      uomId:
      JsonUtils.parseInt(json['uomId']) ?? 0,

      uom: UOM.fromJson(
        JsonUtils.ensureMap(json['uom']),
      ),

      productGroupId:
      JsonUtils.parseInt(
        json['productGroupId'],
      ) ??
          0,

      productGroup: ProductGroup.fromJson(
        JsonUtils.ensureMap(
          json['productGroup'],
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {

    return {

      'id': id,

      'code': code,

      'name': name,

      'price': price,

      'quantity': quantity,

      'uomId': uomId,

      'uom': uom.toJson(),

      'productGroupId': productGroupId,

      'productGroup':
      productGroup?.toJson(),
    };
  }

  Map<String, dynamic> toCreateJson() => {

    'Id': id,

    'Code': code,

    'Name': name,

    'Price': price,

    'Quantity': quantity,

    'UOMId': uomId,

    'ProductGroupId': productGroupId,
  };

  Map<String, dynamic> toUpdateJson() => {

    'id': id,

    'code': code,

    'name': name,

    'price': price,

    'quantity': quantity,

    'uomId': uomId,

    'productGroupId': productGroupId,
  };
}