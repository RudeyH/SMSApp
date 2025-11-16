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
      id: JsonUtils.parseInt(json['Id']),
      code: JsonUtils.parseString(json['Code']),
      name: JsonUtils.parseString(json['Name']),
      price: JsonUtils.parseDouble(json['Price']),
      quantity: JsonUtils.parseDouble(json['Quantity']),
      uomId: JsonUtils.parseInt(json['UOMId']) ?? 0,
      uom: UOM.fromJson(JsonUtils.ensureMap(json['UOM'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Code': code,
      'Name': name,
      'Price': price,
      'Quantity': quantity,
      'UOMId': uomId,
      'UOM': uom.toJson(),
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
    'Id': id,
    'Code': code,
    'Name': name,
    'Price': price,
    'Quantity': quantity,
    'UOMId': uomId,
  };
}
