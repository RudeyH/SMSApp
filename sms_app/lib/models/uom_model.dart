class UOM {
  final int? id;
  final String code;
  final String name;

  UOM({
    this.id,
    required this.code,
    required this.name,
  });

  factory UOM.fromJson(Map<String, dynamic> json) {
    return UOM(
      id: json['Id'] is int
          ? json['Id']
          : int.tryParse(json['Id']?.toString() ?? ''),
      code: json['Code'] ?? '',
      name: json['Name'] ?? '',
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
