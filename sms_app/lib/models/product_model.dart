import 'package:sms_app/models/uom_model.dart';

import '../utils/json_utils.dart';

class Product {
  final int? id;
  final String code;
  final String name;
  final double price;
  final double quantity;
  final int uomId;
  UOM uom;

  Product({
    this.id,
    required this.code,
    required this.name,
    required this.price,
    required this.quantity,
    required this.uomId,
    required this.uom,
  });

  factory Product.fromJson(Map<String, dynamic>? json) {
    json = json ?? {};
    return Product(
      id: JsonUtils.parseInt(json['id']),
      code: JsonUtils.parseString(json['code']),
      name: JsonUtils.parseString(json['name']),
      price: JsonUtils.parseDouble(json['price']),
      quantity: JsonUtils.parseDouble(json['quantity']),
      uomId: JsonUtils.parseInt(json['uomId']) ?? 0,
      uom: UOM.fromJson(JsonUtils.ensureMap(json['uom'])),
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
    };
  }

  Map<String, dynamic> toCreateJson() => {
    'Id': id,
    'Code': code,
    'Name': name,
    'Price': price,
    'Quantity': quantity,
    'UOMId': uomId,
  };

  Map<String, dynamic> toUpdateJson() => {
    'id': id,
    'code': code,
    'name': name,
    'price': price,
    'quantity': quantity,
    'uomId': uomId,
  };
}
