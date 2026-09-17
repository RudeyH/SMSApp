// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../enums/app_enums.dart';
// import '../models/sales_order_item_model.dart';
// import '../models/purchase_order_item_model.dart';
// import '../providers/product_provider.dart';
// import '../models/product_group_model.dart';
// import '../screens/product_group_lookup_screen.dart';
//
// class ProductLookupScreen extends ConsumerStatefulWidget {
//   final ProductLookupMode mode;
//
//   const ProductLookupScreen({super.key, required this.mode});
//
//   @override
//   ConsumerState<ProductLookupScreen> createState() =>
//       _ProductLookupScreenState();
// }
//
// class _ProductLookupScreenState extends ConsumerState<ProductLookupScreen> {
//   String _filter = '';
//   ProductGroup? _selectedProductGroup;
//
//   @override
//   Widget build(BuildContext context) {
//     final asyncProducts = ref.watch(productProvider);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           switch (widget.mode) {
//             ProductLookupMode.sales =>
//             'Select Product (Sales Order)',
//
//             ProductLookupMode.purchase =>
//             'Select Product (Purchase Order)',
//
//             ProductLookupMode.report =>
//             'Select Product (Report)',
//           },
//         ),
//       ),
//       body: Column(
//         children: [
//           // 🔍 Search bar for filtering products
//           Padding(
//             padding: const EdgeInsets.all(8),
//             child: TextField(
//               decoration: const InputDecoration(
//                 prefixIcon: Icon(Icons.search),
//                 hintText: 'Filter by code or name...',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(12)),
//                 ),
//               ),
//               onChanged: (val) => setState(() => _filter = val.toLowerCase()),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 8,
//             ),
//             child: Card(
//               child: ListTile(
//                 leading: const Icon(Icons.category),
//                 title: const Text('Product Group'),
//                 subtitle: Text(
//                   _selectedProductGroup == null
//                       ? 'All Product Groups'
//                       : '${_selectedProductGroup!.code} - '
//                       '${_selectedProductGroup!.name}',
//                 ),
//                 trailing: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//
//                     // CLEAR BUTTON
//
//                     if (_selectedProductGroup != null)
//                       IconButton(
//                         icon: const Icon(Icons.clear),
//                         onPressed: () {
//                           setState(() {
//                             _selectedProductGroup = null;
//                           });
//                         },
//                       ),
//
//                     const Icon(Icons.search),
//                   ],
//                 ),
//                 onTap: _selectProductGroup,
//               ),
//             ),
//           ),
//           // 📋 Product list
//           Expanded(
//             child: asyncProducts.when(
//               data: (products) {
//                 // final filtered = products
//                 //     .where((p) =>
//                 // p.code.toLowerCase().contains(_filter) ||
//                 //     p.name.toLowerCase().contains(_filter))
//                 //     .toList();
//                 final filtered = products.where((p) {
//
//                   // TEXT FILTER
//
//                   final matchText =
//                       p.code.toLowerCase().contains(_filter) ||
//                           p.name.toLowerCase().contains(_filter);
//
//                   // PRODUCT GROUP FILTER
//
//                   final matchProductGroup =
//
//                       _selectedProductGroup == null ||
//
//                           p.productGroupId ==
//                               _selectedProductGroup!.id;
//
//                   return matchText && matchProductGroup;
//
//                 }).toList();
//
//                 if (filtered.isEmpty) {
//                   return const Center(child: Text('No matching products.'));
//                 }
//
//                 return ListView.builder(
//                   itemCount: filtered.length,
//                   itemBuilder: (context, index) {
//                     final p = filtered[index];
//
//                     return Card(
//                       margin: const EdgeInsets.symmetric(
//                           horizontal: 10, vertical: 6),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12)),
//                       elevation: 2,
//                       child: ListTile(
//                         title: Text(
//                           '${p.code} - ${p.name}',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                         ),
//                         subtitle: Text(
//                           'Price: ${p.price.toStringAsFixed(2)} | Stock: ${p.quantity}',
//                           style: const TextStyle(fontSize: 14),
//                         ),
//                         onTap: () async {
//                           if (widget.mode == ProductLookupMode.report) {
//                             Navigator.pop(context, p);
//                             return;
//                           }
//
//                           // 🧩 Prevent selecting zero-stock product for sales
//                           if (widget.mode == ProductLookupMode.sales &&
//                               p.quantity == 0) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text(
//                                   "Cannot select this product. Quantity is 0.",
//                                 ),
//                                 backgroundColor: Colors.redAccent,
//                               ),
//                             );
//                             return;
//                           }
//
//                           final qtyController =
//                           TextEditingController(text: '1');
//                           final priceController = TextEditingController(
//                               text: p.price.toStringAsFixed(2));
//
//                           // 🧾 Show quantity + price dialog
//                           final result = await showDialog<
//                               Map<String, double>>(
//                             context: context,
//                             builder: (dialogContext) => AlertDialog(
//                               title: Text('Order ${p.name}'),
//                               content: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text('Current stock: ${p.quantity}'),
//                                   const SizedBox(height: 10),
//                                   TextField(
//                                     controller: qtyController,
//                                     keyboardType:
//                                     const TextInputType.numberWithOptions(
//                                         decimal: true),
//                                     decoration: const InputDecoration(
//                                         labelText: 'Enter quantity'),
//                                   ),
//                                   const SizedBox(height: 10),
//                                   TextField(
//                                     controller: priceController,
//                                     keyboardType:
//                                     const TextInputType.numberWithOptions(
//                                         decimal: true),
//                                     decoration: const InputDecoration(
//                                         labelText: 'Enter price'),
//                                   ),
//                                 ],
//                               ),
//                               actions: [
//                                 TextButton(
//                                   onPressed: () =>
//                                       Navigator.pop(dialogContext),
//                                   child: const Text('Cancel'),
//                                 ),
//                                 TextButton(
//                                   onPressed: () {
//                                     final qty =
//                                         double.tryParse(qtyController.text) ??
//                                             1;
//                                     final price = double.tryParse(
//                                         priceController.text) ??
//                                         p.price;
//
//                                     // 🧩 Prevent overselling
//                                     if (widget.mode == ProductLookupMode.sales &&
//                                         qty > p.quantity) {
//                                       ScaffoldMessenger.of(context)
//                                           .showSnackBar(
//                                         const SnackBar(
//                                           content: Text(
//                                               "Quantity is more than stock quantity."),
//                                           backgroundColor: Colors.redAccent,
//                                         ),
//                                       );
//                                       return;
//                                     }
//
//                                     Navigator.pop(dialogContext,
//                                         {'qty': qty, 'price': price});
//                                   },
//                                   child: const Text('Add'),
//                                 ),
//                               ],
//                             ),
//                           );
//
//                           if (result != null && context.mounted) {
//                             final qty = result['qty'] ?? 1;
//                             final price = result['price'] ?? p.price;
//
//                             if (widget.mode == ProductLookupMode.sales) {
//                               Navigator.pop(
//                                 context,
//                                 SalesOrderItem(
//                                   productId: p.id ?? 0,
//                                   product: p,
//                                   quantity: qty,
//                                   unitPrice: price,
//                                 ),
//                               );
//                             } else {
//                               Navigator.pop(
//                                 context,
//                                 PurchaseOrderItem(
//                                   productId: p.id ?? 0,
//                                   product: p,
//                                   quantity: qty,
//                                   unitPrice: price,
//                                 ),
//                               );
//                             }
//                           }
//                         },
//                       ),
//                     );
//                   },
//                 );
//               },
//               loading: () =>
//               const Center(child: CircularProgressIndicator()),
//               error: (e, _) => Center(child: Text('Error: $e')),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _selectProductGroup() async {
//
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) =>
//         const ProductGroupLookupScreen(),
//       ),
//     );
//
//     if (result != null && mounted) {
//
//       setState(() {
//
//         _selectedProductGroup =
//         result['productGroup'];
//       });
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../enums/app_enums.dart';
import '../models/sales_order_item_model.dart';
import '../models/purchase_order_item_model.dart';
import '../providers/product_provider.dart';
import '../models/product_group_model.dart';
import '../screens/product_group_lookup_screen.dart';

class ProductLookupScreen extends ConsumerStatefulWidget {
  final ProductLookupMode mode;

  const ProductLookupScreen({super.key, required this.mode});

  @override
  ConsumerState<ProductLookupScreen> createState() =>
      _ProductLookupScreenState();
}

class _ProductLookupScreenState extends ConsumerState<ProductLookupScreen> {
  String _filter = '';
  ProductGroup? _selectedProductGroup;

  @override
  Widget build(BuildContext context) {
    // Only load/watch products AFTER a product group has been selected.
    final asyncProducts = _selectedProductGroup != null
        ? ref.watch(productByGroupProvider(_selectedProductGroup!.id!))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(switch (widget.mode) {
          ProductLookupMode.sales => 'Select Product (Sales Order)',
          ProductLookupMode.purchase => 'Select Product (Purchase Order)',
          ProductLookupMode.report => 'Select Product (Report)',
        }),
      ),
      body: Column(
        children: [
          // Product group selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.category),
                title: const Text('Product Group'),
                subtitle: Text(
                  _selectedProductGroup == null
                      ? 'Select a Product Group'
                      : '${_selectedProductGroup!.code} - '
                            '${_selectedProductGroup!.name}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_selectedProductGroup != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Clear Product Group',
                        onPressed: () {
                          setState(() {
                            _selectedProductGroup = null;
                            _filter = '';
                          });
                        },
                      ),
                    const Icon(Icons.search),
                  ],
                ),
                onTap: _selectProductGroup,
              ),
            ),
          ),

          // Search/filter widget
          //
          // HIDDEN until a product group is selected.
          if (_selectedProductGroup != null)
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
                onChanged: (val) {
                  setState(() {
                    _filter = val.toLowerCase();
                  });
                },
              ),
            ),

          // Product list
          Expanded(
            child: _selectedProductGroup == null
                ? const Center(
                    child: Text(
                      'Please select a Product Group first.',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : asyncProducts!.when(
                    data: (products) {
                      // Text filter only.
                      //
                      // The product provider is expected to load
                      // products for the selected product group.
                      final filtered = products.where((p) {
                        final matchText =
                            p.code.toLowerCase().contains(_filter) ||
                            p.name.toLowerCase().contains(_filter);

                        return matchText;
                      }).toList();

                      if (filtered.isEmpty) {
                        return const Center(
                          child: Text('No matching products.'),
                        );
                      }

                      return ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final p = filtered[index];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                                'Price: ${p.price.toStringAsFixed(2)} | '
                                'Stock: ${p.quantity}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              onTap: () async {
                                if (widget.mode == ProductLookupMode.report) {
                                  Navigator.pop(context, p);
                                  return;
                                }

                                // Prevent selecting zero-stock product
                                // for sales.
                                if (widget.mode == ProductLookupMode.sales &&
                                    p.quantity == 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Cannot select this product. '
                                        'Quantity is 0.',
                                      ),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                  return;
                                }

                                final qtyController = TextEditingController(
                                  text: '1',
                                );

                                final priceController = TextEditingController(
                                  text: p.price.toStringAsFixed(2),
                                );

                                final result = await showDialog<Map<String, double>>(
                                  context: context,
                                  builder: (dialogContext) => AlertDialog(
                                    title: Text('Order ${p.name}'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Current stock: ${p.quantity}'),
                                        const SizedBox(height: 10),
                                        TextField(
                                          controller: qtyController,
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          decoration: const InputDecoration(
                                            labelText: 'Enter quantity',
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        TextField(
                                          controller: priceController,
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          decoration: const InputDecoration(
                                            labelText: 'Enter price',
                                          ),
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
                                              double.tryParse(
                                                qtyController.text,
                                              ) ??
                                              1;

                                          final price =
                                              double.tryParse(
                                                priceController.text,
                                              ) ??
                                              p.price;

                                          // Prevent overselling.
                                          if (widget.mode ==
                                                  ProductLookupMode.sales &&
                                              qty > p.quantity) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Quantity is more than '
                                                  'stock quantity.',
                                                ),
                                                backgroundColor:
                                                    Colors.redAccent,
                                              ),
                                            );
                                            return;
                                          }

                                          Navigator.pop(dialogContext, {
                                            'qty': qty,
                                            'price': price,
                                          });
                                        },
                                        child: const Text('Add'),
                                      ),
                                    ],
                                  ),
                                );

                                if (result != null && context.mounted) {
                                  final qty = result['qty'] ?? 1;
                                  final price = result['price'] ?? p.price;

                                  if (widget.mode == ProductLookupMode.sales) {
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

  Future<void> _selectProductGroup() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProductGroupLookupScreen()),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedProductGroup = result['productGroup'];
        _filter = '';
      });
    }
  }
}
