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
      id: JsonUtils.parseInt(json['Id']),
      code: JsonUtils.parseString(json['Code']),
      name: JsonUtils.parseString(json['Name']),
      address: JsonUtils.parseString(json['Address']),
      contactNo: JsonUtils.parseString(json['ContactNo']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Code': code,
      'Name': name,
      'Address': address,
      'ContactNo': contactNo,
    };
  }
}
