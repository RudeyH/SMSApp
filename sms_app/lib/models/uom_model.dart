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
      id: JsonUtils.parseInt(json['id']),
      code: JsonUtils.parseString(json['code']),
      name: JsonUtils.parseString(json['name']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
    };
  }
}
