import '../utils/json_utils.dart';

class ProductGroup {
  final int? id;
  final String code;
  final String name;

  ProductGroup({
    this.id,
    required this.code,
    required this.name,
  });

  factory ProductGroup.fromJson(Map<String, dynamic>? json) {
    json = json ?? {};

    return ProductGroup(
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
