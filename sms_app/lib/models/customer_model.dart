import '../utils/json_utils.dart';

class Customer {
  final int? id;
  final String code;
  final String name;
  final String address;
  final String contactNo;

  Customer({
    this.id,
    required this.code,
    required this.name,
    required this.address,
    required this.contactNo,
  });

  factory Customer.fromJson(Map<String, dynamic>? json) {
    json = json ?? {};
    return Customer(
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
