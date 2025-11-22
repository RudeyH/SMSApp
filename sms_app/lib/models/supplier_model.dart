import '../utils/json_utils.dart';

class Supplier {
  final int? id;
  final String code;
  final String name;
  final String address;
  final String contactNo;

  Supplier({
    this.id,
    required this.code,
    required this.name,
    required this.address,
    required this.contactNo,
  });

  factory Supplier.fromJson(Map<String, dynamic>? json) {
    json = json ?? {};
    return Supplier(
      id: JsonUtils.parseInt(json['id']),
      code: JsonUtils.parseString(json['code']),
      name: JsonUtils.parseString(json['name']),
      address: JsonUtils.parseString(json['address']),
      contactNo: JsonUtils.parseString(json['contactNo']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'address': address,
      'contactNo': contactNo,
    };
  }
}
