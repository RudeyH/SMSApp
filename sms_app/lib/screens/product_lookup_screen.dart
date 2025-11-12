import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sales_order_item_model.dart';
import '../models/purchase_order_item_model.dart';
import '../providers/product_provider.dart';

class ProductLookupScreen extends ConsumerStatefulWidget {
  final String source; // "sales" or "purchase"

  const ProductLookupScreen({super.key, required this.source});

  @override
  ConsumerState<ProductLookupScreen> createState() =>
      _ProductLookupScreenState();
}

class _ProductLookupScreenState extends ConsumerState<ProductLookupScreen> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final asyncProducts = ref.watch(productProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Product (${widget.source == "sales" ? "Sales Order" : "Purchase Order"})',
        ),
      ),
      body: Column(
        children: [
          // 🔍 Search bar for filtering products
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Filter by code or name...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              onChanged: (val) => setState(() => _filter = val.toLowerCase()),
            ),
          ),

          // 📋 Product list
          Expanded(
            child: asyncProducts.when(
              data: (products) {
                final filtered = products
                    .where((p) =>
                p.code.toLowerCase().contains(_filter) ||
                    p.name.toLowerCase().contains(_filter))
                    .toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No matching products.'));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final p = filtered[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: ListTile(
                        title: Text(
                          '${p.code} - ${p.name}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          'Price: ${p.price.toStringAsFixed(2)} | Stock: ${p.quantity}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        onTap: () async {
                          // 🧩 Prevent selecting zero-stock product for sales
                          if (widget.source == "sales" && p.quantity == 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "Cannot select this product. Quantity is 0."),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          final qtyController =
                          TextEditingController(text: '1');
                          final priceController = TextEditingController(
                              text: p.price.toStringAsFixed(2));

                          // 🧾 Show quantity + price dialog
                          final result = await showDialog<
                              Map<String, double>>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: Text('Order ${p.name}'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Current stock: ${p.quantity}'),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: qtyController,
                                    keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                    decoration: const InputDecoration(
                                        labelText: 'Enter quantity'),
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: priceController,
                                    keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                    decoration: const InputDecoration(
                                        labelText: 'Enter price'),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    final qty =
                                        double.tryParse(qtyController.text) ??
                                            1;
                                    final price = double.tryParse(
                                        priceController.text) ??
                                        p.price;

                                    // 🧩 Prevent overselling
                                    if (widget.source == "sales" &&
                                        qty > p.quantity) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Quantity is more than stock quantity."),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                      return;
                                    }

                                    Navigator.pop(dialogContext,
                                        {'qty': qty, 'price': price});
                                  },
                                  child: const Text('Add'),
                                ),
                              ],
                            ),
                          );

                          if (result != null && context.mounted) {
                            final qty = result['qty'] ?? 1;
                            final price = result['price'] ?? p.price;

                            if (widget.source == 'sales') {
                              Navigator.pop(
                                context,
                                SalesOrderItem(
                                  productId: p.id ?? 0,
                                  product: p,
                                  quantity: qty,
                                  unitPrice: price,
                                ),
                              );
                            } else {
                              Navigator.pop(
                                context,
                                PurchaseOrderItem(
                                  productId: p.id ?? 0,
                                  product: p,
                                  quantity: qty,
                                  unitPrice: price,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    );
                  },
                );
              },
              loading: () =>
              const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/sales_order_item_model.dart';
// import '../models/purchase_order_item_model.dart';
// import '../providers/product_provider.dart';
//
// class ProductLookupScreen extends ConsumerWidget {
//   final String source; // "sales" or "purchase"
//
//   const ProductLookupScreen({super.key, required this.source});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final asyncProducts = ref.watch(productProvider);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Select Product (${source == "sales" ? "Sales Order" : "Purchase Order"})',
//         ),
//       ),
//       body: asyncProducts.when(
//         data: (products) => ListView.builder(
//           itemCount: products.length,
//           itemBuilder: (context, index) {
//             final p = products[index];
//
//             return ListTile(
//               title: Text(p.name),
//               subtitle: Text('Price: ${p.price} || Stock Quantity: ${p.quantity}'),
//               onTap: () async {
//                 // 🧩 Condition #1 — prevent selecting zero-stock product for sales
//                 if (source == "sales" && p.quantity == 0) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text("Cannot select this product. Quantity is 0."),
//                       backgroundColor: Colors.redAccent,
//                     ),
//                   );
//                   return;
//                 }
//
//                 final qtyController = TextEditingController(text: '1');
//                 final priceController = TextEditingController(text: p.price.toStringAsFixed(2));
//
//                 final result = await showDialog<Map<String, double>>(
//                   context: context,
//                   builder: (dialogContext) => AlertDialog(
//                     title: Text('Order ${p.name}'),
//                     content: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Current stock: ${p.quantity}'),
//                         const SizedBox(height: 10),
//                         TextField(
//                           controller: qtyController,
//                           keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                           decoration: const InputDecoration(labelText: 'Enter quantity'),
//                         ),
//                         const SizedBox(height: 10),
//                         TextField(
//                           controller: priceController,
//                           keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                           decoration: const InputDecoration(labelText: 'Enter price'),
//                         ),
//                       ],
//                     ),
//                     actions: [
//                       TextButton(
//                         onPressed: () => Navigator.pop(dialogContext),
//                         child: const Text('Cancel'),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           final qty = double.tryParse(qtyController.text) ?? 1;
//                           final price = double.tryParse(priceController.text) ?? p.price;
//
//                           // 🧩 Condition #4 — prevent overselling
//                           if (source == "sales" && qty > p.quantity) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text("Quantity is more than stock quantity."),
//                                 backgroundColor: Colors.redAccent,
//                               ),
//                             );
//                             return;
//                           }
//
//                           Navigator.pop(dialogContext, {'qty': qty, 'price': price});
//                         },
//                         child: const Text('Add'),
//                       ),
//                     ],
//                   ),
//                 );
//
//                 if (result != null && context.mounted) {
//                   final qty = result['qty'] ?? 1;
//                   final price = result['price'] ?? p.price;
//
//                   if (source == 'sales') {
//                     Navigator.pop(
//                       context,
//                       SalesOrderItem(
//                         productId: p.id ?? 0,
//                         product: p,
//                         quantity: qty,
//                         unitPrice: price,
//                       ),
//                     );
//                   } else {
//                     Navigator.pop(
//                       context,
//                       PurchaseOrderItem(
//                         productId: p.id ?? 0,
//                         product: p,
//                         quantity: qty,
//                         unitPrice: price,
//                       ),
//                     );
//                   }
//                 }
//               },
//             );
//           },
//         ),
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (e, _) => Center(child: Text('Error: $e')),
//       ),
//     );
//   }
// }
