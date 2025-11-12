import 'package:sms_app/models/sales_order_item_model.dart';
import 'customer_model.dart';

class SalesOrder {
  int? id;
  final String transNumber;
  final DateTime transDate;
  final int customerId;
  Customer customer;
  final double grandTotal;
  final List<SalesOrderItem> items;

  SalesOrder({
    this.id,
    required this.transNumber,
    required this.transDate,
    required this.customerId,
    required this.customer,
    required this.grandTotal,
    required this.items,
  });

    factory SalesOrder.fromJson(Map<String, dynamic> json) => SalesOrder(
    id: json['Id'],
    transNumber: json['TransNumber'],
    transDate: DateTime.parse(json['TransDate']),
    customerId: json['CustomerId'],
    customer: Customer.fromJson(json['Customer']),
    grandTotal: json['GrandTotal'],
    items: (json['Items'] as List)
        .map((i) => SalesOrderItem.fromJson(i))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'Id': id,
    'TransNumber': transNumber,
    'TransDate': transDate.toIso8601String(),
    'CustomerId': customerId,
    'Customer': customer.toJson(),
    'GrandTotal': grandTotal,
    'Items': items.map((i) => i.toJson()).toList(),
  };

  Map<String, dynamic> toCreateJson() => {
    'TransNumber': transNumber,
    'TransDate': transDate.toIso8601String(),
    'CustomerId': customerId,
    'GrandTotal': grandTotal,
    'Items': items.map((i) => i.toCreateJson()).toList(),
  };

  Map<String, dynamic> toUpdateJson() => {
    'Id': id,
    'TransNumber': transNumber,
    'TransDate': transDate.toIso8601String(),
    'CustomerId': customerId,
    'GrandTotal': grandTotal,
    'Items': items.map((i) => i.toCreateJson()).toList(),
  };
}

