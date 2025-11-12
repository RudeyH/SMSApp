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

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
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
