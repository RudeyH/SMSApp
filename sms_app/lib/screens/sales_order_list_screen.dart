import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sales_order_model.dart';
import '../providers/sales_order_provider.dart';
import '../widgets/swipeable_list_tile.dart';
import '../widgets/sticky_search_bar.dart';
import 'sales_order_detail_screen.dart';

class SalesOrderListScreen extends ConsumerStatefulWidget {
  const SalesOrderListScreen({super.key});

  @override
  ConsumerState<SalesOrderListScreen> createState() =>
      _SalesOrderListScreenState();
}

class _SalesOrderListScreenState extends ConsumerState<SalesOrderListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Load more when scrolling to bottom
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        ref.read(salesOrderProvider.notifier).loadMore();
      }
    });
  }

  Future<void> _refreshData() async {
    await ref.read(salesOrderProvider.notifier).refresh();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(salesOrderProvider);
    final notifier = ref.read(salesOrderProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Orders'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              notifier.toggleSort(value);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'transNumber',
                child: Text('Transaction Number'),
              ),
              const PopupMenuItem(
                value: 'customer code',
                child: Text('Customer Code'),
              ),
              const PopupMenuItem(
                value: 'customer name',
                child: Text('Customer Name'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Text(
                notifier.sortLabel,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
      body: dataAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No sales orders available.'));
          }

          final query = _searchController.text.toLowerCase();
          final filteredItems = items.where((order) {
            return order.transNumber.toLowerCase().contains(query) ||
                order.customer.name.toLowerCase().contains(query);
          }).toList();

          return RefreshIndicator(
            color: Colors.blueAccent,
            onRefresh: _refreshData,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: StickySearchBar(
                    controller: _searchController,
                    hintText: 'Search by number or customer...',
                    onChanged: (query) {
                      notifier.search(query);
                    },
                  ),
                ),
                SliverList.builder(
                  itemCount: filteredItems.length + 1,
                  itemBuilder: (_, index) {
                    if (index == filteredItems.length) {
                      // show loader at bottom if more pages exist
                      if (notifier.hasMore) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              )),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }

                    final order = filteredItems[index];
                    return SwipeableListTile<SalesOrder>(
                      item: order,
                      deleteConfirmMessage:
                      'Are you sure you want to delete "${order.transNumber}"?',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SalesOrderDetailScreen(data: order),
                          ),
                        );
                      },
                      onDelete: () async {
                        if (order.id != null) {
                          await ref
                              .read(salesOrderActionProvider.notifier)
                              .deleteData(order.id!);
                          await notifier.refresh();
                        }
                      },
                      contentBuilder: (_, data) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.transNumber,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Customer: ${data.customer.name}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            'Date: ${data.transDate.toLocal().toString().split(' ')[0]}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            'Total: ${data.grandTotal.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(
            'Error: $err',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SalesOrderDetailScreen(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/sales_order_model.dart';
// import '../providers/sales_order_provider.dart';
// import '../widgets/swipeable_list_tile.dart';
// import '../widgets/sticky_search_bar.dart';
// import 'sales_order_detail_screen.dart';
//
// class SalesOrderListScreen extends ConsumerStatefulWidget {
//   const SalesOrderListScreen({super.key});
//
//   @override
//   ConsumerState<SalesOrderListScreen> createState() =>
//       _SalesOrderListScreenState();
// }
//
// class _SalesOrderListScreenState extends ConsumerState<SalesOrderListScreen> {
//   final TextEditingController _searchController = TextEditingController();
//
//   Future<void> _refreshData() async {
//     ref.invalidate(salesOrderProvider);
//     await Future.delayed(const Duration(milliseconds: 300));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final dataAsync = ref.watch(salesOrderProvider);
//
//     return Scaffold(
//       body: dataAsync.when(
//         data: (items) {
//           if (items.isEmpty) {
//             return const Center(child: Text('No sales orders available.'));
//           }
//
//           final query = _searchController.text.toLowerCase();
//           final filteredItems = items.where((order) {
//             return order.transNumber.toLowerCase().contains(query) ||
//                 order.customer.name.toLowerCase().contains(query);
//           }).toList();
//
//           return RefreshIndicator(
//             color: Colors.blueAccent,
//             onRefresh: _refreshData,
//             child: CustomScrollView(
//               slivers: [
//                 SliverToBoxAdapter(
//                   child: StickySearchBar(
//                     controller: _searchController,
//                     hintText: 'Search by number or customer...',
//                     onChanged: (_) => setState(() {}),
//                   ),
//                 ),
//                 SliverList.builder(
//                   itemCount: filteredItems.length,
//                   itemBuilder: (_, index) {
//                     final order = filteredItems[index];
//                     return SwipeableListTile<SalesOrder>(
//                       item: order,
//                       deleteConfirmMessage:
//                       'Are you sure you want to delete "${order.transNumber}"?',
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) =>
//                                 SalesOrderDetailScreen(data: order),
//                           ),
//                         );
//                       },
//                       onDelete: () async {
//                         if (order.id != null) {
//                           await ref
//                               .read(salesOrderActionProvider.notifier)
//                               .deleteData(order.id!);
//                         }
//                       },
//                       contentBuilder: (_, data) => Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             data.transNumber,
//                             style: const TextStyle(
//                                 fontSize: 16, fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(height: 4),
//                           Text('Customer: ${data.customer.name}',
//                               style: const TextStyle(fontSize: 14)),
//                           Text(
//                             'Date: ${data.transDate.toLocal().toString().split(' ')[0]}',
//                             style: const TextStyle(fontSize: 14),
//                           ),
//                           Text('Total: ${data.grandTotal.toStringAsFixed(2)}',
//                               style: const TextStyle(fontSize: 14)),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           );
//         },
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (err, _) => Center(child: Text('Error: $err')),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => const SalesOrderDetailScreen(),
//           ),
//         ),
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/sales_order_model.dart';
// import 'package:sms_app/providers/sales_order_provider.dart';
// import 'package:sms_app/screens/sales_order_detail_screen.dart';
// import '../widgets/swipeable_list_tile.dart';
//
// class SalesOrderListScreen extends ConsumerStatefulWidget {
//   const SalesOrderListScreen({super.key});
//
//   @override
//   ConsumerState<SalesOrderListScreen> createState() =>
//       _SalesOrderListScreenState();
// }
//
// class _SalesOrderListScreenState extends ConsumerState<SalesOrderListScreen> {
//   Future<void> _refreshData() async {
//     ref.invalidate(salesOrderProvider);
//     await Future.delayed(const Duration(milliseconds: 300));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     ref.listen<AsyncValue<void>>(salesOrderActionProvider, (previous, next) {
//       next.whenOrNull(
//         data: (_) {
//           if (!mounted) return;
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Action completed successfully!'),
//               backgroundColor: Colors.green,
//             ),
//           );
//           ref.invalidate(salesOrderProvider); // refresh product list
//         },
//         error: (error, _) {
//           if (!mounted) return;
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Error: $error'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         },
//       );
//     });
//
//     final dataAsync = ref.watch(salesOrderProvider);
//
//     return Scaffold(
//       body: dataAsync.when(
//         data: (items) {
//           if (items.isEmpty) {
//             return const Center(child: Text('No data available.'));
//           }
//
//           return RefreshIndicator(
//             color: Colors.blueAccent,
//             onRefresh: _refreshData,
//             child: ListView.builder(
//               physics: const AlwaysScrollableScrollPhysics(),
//               itemCount: items.length,
//               itemBuilder: (_, index) {
//                 final item = items[index];
//
//                 return SwipeableListTile<SalesOrder>(
//                   item: item,
//                   deleteConfirmMessage:
//                   'Are you sure you want to delete "${item.transNumber}"?',
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) =>
//                             SalesOrderDetailScreen(data: item),
//                       ),
//                     );
//                   },
//                   onDelete: () async {
//                     if (item.id != null) {
//                       await ref
//                           .read(salesOrderActionProvider.notifier)
//                           .deleteData(item.id!);
//                     }
//                   },
//                   contentBuilder: (_, data) => Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                           data.transNumber,
//                           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 4),
//                       Text('Date: ${item.transDate}',
//                           style: const TextStyle(fontSize: 14)),
//                       Text('Supplier: [ ${item.customer.code} ] ${item.customer.name}',
//                           style: const TextStyle(fontSize: 14, color: Colors.green)),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           );
//         },
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (err, _) => Center(child: Text('Error: $err')),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => const SalesOrderDetailScreen(),
//           ),
//         ),
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
