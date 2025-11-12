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

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['Id'] is int
          ? json['Id']
          : int.tryParse(json['Id']?.toString() ?? ''),
      code: json['Code'] ?? '',
      name: json['Name'] ?? '',
      address: json['Address'] ?? '',
      contactNo: json['ContactNo'] ?? '',
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
