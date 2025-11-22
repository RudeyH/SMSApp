import 'package:flutter/material.dart';
import '../config.dart';
import '../models/customer_model.dart';
import '../screens/customer_detail_screen.dart';
import 'generic_list_config.dart';

final customerConfig = GenericListConfig<Customer>(
  baseUrl: "${Config().baseUrl}/customer",
  storageKey: "customer",
  fromJson: Customer.fromJson,

  sortFields: {
    "name": (c) => c.name,
    "code": (c) => c.code,
    "contactNo": (c) => c.contactNo,
  },

  itemBuilder: (ctx, c) => Padding(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(c.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text("Code: ${c.code}"),
        Text("Contact: ${c.contactNo}"),
      ],
    ),
  ),

  onTap: (ctx, c) {
    Navigator.push(ctx, MaterialPageRoute(
      builder: (_) => CustomerDetailScreen(data: c),
    ));
  },

  addScreenBuilder: () => const CustomerDetailScreen(),
);
