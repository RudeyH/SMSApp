import '../utils/json_utils.dart';

class UOM {
  final int? id;
  final String code;
  final String name;

  UOM({
    this.id,
    required this.code,
    required this.name,
  });

  factory UOM.fromJson(Map<String, dynamic>? json) {
    json = json ?? {};

    return UOM(
      id: JsonUtils.parseInt(json['Id']),
      code: JsonUtils.parseString(json['Code']),
      name: JsonUtils.parseString(json['Name']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Code': code,
      'Name': name,
    };
  }
}
