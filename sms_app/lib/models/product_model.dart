import 'package:sms_app/models/uom_model.dart';

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

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['Id'] is int
          ? json['Id']
          : int.tryParse(json['Id']?.toString() ?? ''),
      code: json['Code'] ?? '',
      name: json['Name'] ?? '',
      price: (json['Price'] is num)
          ? (json['Price'] as num).toDouble()
          : double.tryParse(json['Price']?.toString() ?? '0') ?? 0,
      quantity: (json['Quantity'] is num)
          ? (json['Quantity'] as num).toDouble()
          : double.tryParse(json['Quantity']?.toString() ?? '0') ?? 0,
      uomId: json['UOMId'],
      uom: UOM.fromJson(json['UOM']),
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
