import 'package:sms_app/models/sales_order_item_model.dart';
import '../utils/json_utils.dart';
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

  factory SalesOrder.fromJson(Map<String, dynamic>? json) {
    json = json ?? {};

    return SalesOrder(
      id: JsonUtils.parseInt(json['Id']),
      transNumber: JsonUtils.parseString(json['TransNumber']),
      transDate: _parseDate(json['TransDate']),
      customerId: JsonUtils.parseInt(json['CustomerId']) ?? 0,
      customer: Customer.fromJson(JsonUtils.ensureMap(json['Customer'])),
      grandTotal: JsonUtils.parseDouble(json['GrandTotal']),
      items: _parseItems(json['Items']),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    final str = JsonUtils.parseString(value);
    return DateTime.tryParse(str) ?? DateTime.now();
  }

  static List<SalesOrderItem> _parseItems(dynamic items) {
    if (items is List) {
      return items
          .map((e) => SalesOrderItem.fromJson(JsonUtils.ensureMap(e)))
          .toList();
    }
    return <SalesOrderItem>[];
  }

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

