import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../widgets/swipeable_list_tile.dart';
import '../widgets/sticky_search_bar.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final notifier = ref.read(productProvider.notifier);
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      notifier.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(productProvider);
    final notifier = ref.read(productProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: dataAsync.when(
          data: (items) => RefreshIndicator(
            onRefresh: notifier.refresh,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // 🔍 Search Bar
                SliverAppBar(
                  pinned: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  automaticallyImplyLeading: false,
                  elevation: 2,
                  titleSpacing: 0,
                  title: StickySearchBar(
                    controller: _searchController,
                    hintText: 'Search products...',
                    onChanged: notifier.search,
                  ),
                ),

                // 📌 Sticky Sort Summary Bar
                // inside the _StickyHeaderDelegate child (Sorted by bar)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyHeaderDelegate(
                    child: Container(
                      color: Theme.of(context).cardColor,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sorted by: ${notifier.sortLabel}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 14),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.sort),
                            onSelected: (value) {
                              notifier.toggleSort(value);
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'name',
                                child: Text('Name'),
                              ),
                              const PopupMenuItem(
                                value: 'code',
                                child: Text('Code'),
                              ),
                              const PopupMenuItem(
                                value: 'price',
                                child: Text('Price'),
                              ),
                              const PopupMenuItem(
                                value: 'quantity',
                                child: Text('Quantity'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),


                // 📦 Product List
                SliverList.builder(
                  itemCount: items.length + 1,
                  itemBuilder: (context, index) {
                    if (index == items.length) {
                      if (notifier.hasMore) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: Text('End of List')),
                        );
                      }
                    }

                    final product = items[index];
                    return SwipeableListTile<Product>(
                      item: product,
                      deleteConfirmMessage:
                      'Delete product "${product.name}"?',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(data: product),
                          ),
                        );
                      },
                      onDelete: () async {
                        // handle delete here (if needed)
                      },
                      contentBuilder: (_, data) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.name,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text('Code: ${data.code}'),
                          Text('Price: Rp ${data.price.toStringAsFixed(2)}'),
                          Text('Qty: ${data.quantity}'),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ProductDetailScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// 📌 Sticky Header Delegate
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickyHeaderDelegate({required this.child});

  @override
  double get minExtent => 40;
  @override
  double get maxExtent => 40;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) => false;
}


// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/product_model.dart';
// import '../providers/product_provider.dart';
// import '../widgets/swipeable_list_tile.dart';
// import '../widgets/sticky_search_bar.dart';
// import 'product_detail_screen.dart';
//
// class ProductListScreen extends ConsumerStatefulWidget {
//   const ProductListScreen({super.key});
//
//   @override
//   ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
// }
//
// class _ProductListScreenState extends ConsumerState<ProductListScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';
//
//   Future<void> _refreshData() async {
//     ref.invalidate(productProvider);
//     await Future.delayed(const Duration(milliseconds: 300));
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     ref.listen<AsyncValue<void>>(productActionProvider, (previous, next) {
//       next.whenOrNull(
//         data: (_) {
//           if (!mounted) return;
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Action completed successfully!'),
//               backgroundColor: Colors.green,
//             ),
//           );
//           ref.invalidate(productProvider);
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
//     final dataAsync = ref.watch(productProvider);
//
//     return Scaffold(
//       body: SafeArea(
//         child: dataAsync.when(
//           data: (items) {
//             final filteredItems = items
//                 .where((item) =>
//             item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
//                 item.code.toLowerCase().contains(_searchQuery.toLowerCase()))
//                 .toList();
//
//             return RefreshIndicator(
//               color: Colors.blueAccent,
//               onRefresh: _refreshData,
//               child: CustomScrollView(
//                 slivers: [
//                   // 🔍 Sticky Search Bar
//                   SliverAppBar(
//                     pinned: true,
//                     backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//                     automaticallyImplyLeading: false,
//                     elevation: 2,
//                     titleSpacing: 0,
//                     title: StickySearchBar(
//                       controller: _searchController,
//                       hintText: 'Search products...',
//                       onChanged: (value) {
//                         setState(() => _searchQuery = value);
//                       },
//                     ),
//                   ),
//
//                   // 📦 Empty State
//                   if (filteredItems.isEmpty)
//                     const SliverFillRemaining(
//                       hasScrollBody: false,
//                       child: Center(child: Text('No matching products.')),
//                     )
//                   else
//                   // 🧱 Product List
//                     SliverList.builder(
//                       itemCount: filteredItems.length,
//                       itemBuilder: (_, index) {
//                         final item = filteredItems[index];
//
//                         return SwipeableListTile<Product>(
//                           item: item,
//                           deleteConfirmMessage:
//                           'Are you sure you want to delete "${item.name}"?',
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) =>
//                                     ProductDetailScreen(data: item),
//                               ),
//                             );
//                           },
//                           onDelete: () async {
//                             if (item.id != null) {
//                               await ref
//                                   .read(productActionProvider.notifier)
//                                   .deleteData(item.id!);
//                             }
//                           },
//                           contentBuilder: (_, data) => Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 data.name,
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text('Code: ${data.code}',
//                                   style: const TextStyle(fontSize: 14)),
//                               Text(
//                                 'Price: ${data.price.toStringAsFixed(2)}',
//                                 style: const TextStyle(fontSize: 14),
//                               ),
//                               Text(
//                                 'Quantity: ${data.quantity}',
//                                 style: const TextStyle(fontSize: 14),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                 ],
//               ),
//             );
//           },
//           loading: () => const Center(child: CircularProgressIndicator()),
//           error: (err, _) => Center(child: Text('Error: $err')),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => const ProductDetailScreen(),
//           ),
//         ),
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
//
//
// // import 'package:flutter/material.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import '../models/product_model.dart';
// // import '../providers/product_provider.dart';
// // import '../widgets/swipeable_list_tile.dart';
// // import 'product_detail_screen.dart';
// //
// // class ProductListScreen extends ConsumerStatefulWidget {
// //   const ProductListScreen({super.key});
// //
// //   @override
// //   ConsumerState<ProductListScreen> createState() =>
// //       _ProductListScreenState();
// // }
// //
// // class _ProductListScreenState extends ConsumerState<ProductListScreen> {
// //   Future<void> _refreshData() async {
// //     ref.invalidate(productProvider);
// //     await Future.delayed(const Duration(milliseconds: 300));
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     ref.listen<AsyncValue<void>>(productActionProvider, (previous, next) {
// //       next.whenOrNull(
// //         data: (_) {
// //           if (!mounted) return;
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             const SnackBar(
// //               content: Text('Action completed successfully!'),
// //               backgroundColor: Colors.green,
// //             ),
// //           );
// //           ref.invalidate(productProvider); // refresh product list
// //         },
// //         error: (error, _) {
// //           if (!mounted) return;
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             SnackBar(
// //               content: Text('Error: $error'),
// //               backgroundColor: Colors.red,
// //             ),
// //           );
// //         },
// //       );
// //     });
// //
// //     final dataAsync = ref.watch(productProvider);
// //
// //     return Scaffold(
// //       body: dataAsync.when(
// //         data: (items) {
// //           if (items.isEmpty) {
// //             return const Center(child: Text('No data available.'));
// //           }
// //
// //           return RefreshIndicator(
// //             color: Colors.blueAccent,
// //             onRefresh: _refreshData,
// //             child: ListView.builder(
// //               physics: const AlwaysScrollableScrollPhysics(),
// //               itemCount: items.length,
// //               itemBuilder: (_, index) {
// //                 final item = items[index];
// //
// //                 return SwipeableListTile<Product>(
// //                   item: item,
// //                   deleteConfirmMessage:
// //                   'Are you sure you want to delete "${item.name}"?',
// //                   onTap: () {
// //                     Navigator.push(
// //                       context,
// //                       MaterialPageRoute(
// //                         builder: (_) =>
// //                             ProductDetailScreen(data : item),
// //                       ),
// //                     );
// //                   },
// //                   onDelete: () async {
// //                     if (item.id != null) {
// //                       await ref
// //                           .read(productActionProvider.notifier)
// //                           .deleteData(item.id!);
// //                     }
// //                   },
// //                   contentBuilder: (_, data) => Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         data.name,
// //                         style: const TextStyle(
// //                             fontSize: 16, fontWeight: FontWeight.bold),
// //                         ),
// //                       const SizedBox(height: 4),
// //                       Text('Code: ${item.code}',
// //                         style: const TextStyle(fontSize: 14)),
// //                       Text('Price: Rp ${item.price.toStringAsFixed(2)}',
// //                         style: const TextStyle(fontSize: 14, color: Colors.green)),
// //                       Text('Quantity: ${item.quantity.toStringAsFixed(2)}',
// //                         style: const TextStyle(fontSize: 14, color: Colors.green)),
// //                     ],
// //                   ),
// //                 );
// //               },
// //             ),
// //           );
// //         },
// //         loading: () => const Center(child: CircularProgressIndicator()),
// //         error: (err, _) => Center(child: Text('Error: $err')),
// //       ),
// //       floatingActionButton: FloatingActionButton(
// //         onPressed: () => Navigator.push(
// //           context,
// //           MaterialPageRoute(
// //             builder: (_) => const ProductDetailScreen(),
// //           ),
// //         ),
// //         child: const Icon(Icons.add),
// //       ),
// //     );
// //   }
// // }
