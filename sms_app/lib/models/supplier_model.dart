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
