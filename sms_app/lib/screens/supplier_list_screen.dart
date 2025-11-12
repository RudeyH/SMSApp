import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/supplier_model.dart';
import '../providers/supplier_provider.dart';
import '../widgets/swipeable_list_tile.dart';
import '../widgets/sticky_search_bar.dart';
import 'supplier_detail_screen.dart';

class SupplierListScreen extends ConsumerStatefulWidget {
  const SupplierListScreen({super.key});

  @override
  ConsumerState<SupplierListScreen> createState() =>
      _SupplierListScreenState();
}

class _SupplierListScreenState extends ConsumerState<SupplierListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final notifier = ref.read(supplierProvider.notifier);
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
    final dataAsync = ref.watch(supplierProvider);
    final notifier = ref.read(supplierProvider.notifier);

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
                    hintText: 'Search suppliers...',
                    onChanged: notifier.search,
                  ),
                ),

                // 📌 Sticky Sort Bar
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyHeaderDelegate(
                    child: Container(
                      color: Theme.of(context).cardColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sorted by: ${notifier.sortLabel}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.sort),
                            onSelected: notifier.toggleSort,
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
                                value: 'address',
                                child: Text('Address'),
                              ),
                              const PopupMenuItem(
                                value: 'contactNo',
                                child: Text('Contact No'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 📦 Supplier List
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

                    final supplier = items[index];
                    return SwipeableListTile<Supplier>(
                      item: supplier,
                      deleteConfirmMessage:
                      'Are you sure you want to delete "${supplier.name}"?',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                SupplierDetailScreen(data: supplier),
                          ),
                        );
                      },
                      onDelete: () async {
                        if (supplier.id != null) {
                          await ref
                              .read(supplierActionProvider.notifier)
                              .deleteData(supplier.id!);
                          notifier.refresh();
                        }
                      },
                      contentBuilder: (_, data) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('Code: ${data.code}'),
                          Text('Contact: ${data.contactNo}'),
                          Text('Address: ${data.address}'),
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
              builder: (_) => const SupplierDetailScreen(),
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
// import '../models/supplier_model.dart';
// import '../providers/supplier_provider.dart';
// import '../widgets/swipeable_list_tile.dart';
// import '../widgets/sticky_search_bar.dart';
// import 'supplier_detail_screen.dart';
//
// class SupplierListScreen extends ConsumerStatefulWidget {
//   const SupplierListScreen({super.key});
//
//   @override
//   ConsumerState<SupplierListScreen> createState() =>
//       _SupplierListScreenState();
// }
//
// class _SupplierListScreenState extends ConsumerState<SupplierListScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';
//
//   Future<void> _refreshData() async {
//     ref.invalidate(supplierProvider);
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
//     ref.listen<AsyncValue<void>>(supplierActionProvider, (previous, next) {
//       next.whenOrNull(
//         data: (_) {
//           if (!mounted) return;
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Action completed successfully!'),
//               backgroundColor: Colors.green,
//             ),
//           );
//           ref.invalidate(supplierProvider);
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
//     final dataAsync = ref.watch(supplierProvider);
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
//                       hintText: 'Search suppliers...',
//                       onChanged: (value) {
//                         setState(() => _searchQuery = value);
//                       },
//                     ),
//                   ),
//
//                   // 🧾 Empty State
//                   if (filteredItems.isEmpty)
//                     const SliverFillRemaining(
//                       hasScrollBody: false,
//                       child: Center(child: Text('No matching suppliers.')),
//                     )
//                   else
//                   // 🧱 Supplier List
//                     SliverList.builder(
//                       itemCount: filteredItems.length,
//                       itemBuilder: (_, index) {
//                         final item = filteredItems[index];
//
//                         return SwipeableListTile<Supplier>(
//                           item: item,
//                           deleteConfirmMessage:
//                           'Are you sure you want to delete "${item.name}"?',
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) =>
//                                     SupplierDetailScreen(data: item),
//                               ),
//                             );
//                           },
//                           onDelete: () async {
//                             if (item.id != null) {
//                               await ref
//                                   .read(supplierActionProvider.notifier)
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
//                               Text('Contact No: ${data.contactNo}',
//                                   style: const TextStyle(fontSize: 14)),
//                               Text('Address: ${data.address}',
//                                   style: const TextStyle(fontSize: 14)),
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
//             builder: (_) => const SupplierDetailScreen(),
//           ),
//         ),
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/supplier_model.dart';
// import '../providers/supplier_provider.dart';
// import '../widgets/swipeable_list_tile.dart';
// import '../widgets/sticky_search_bar.dart';
// import 'supplier_detail_screen.dart';
//
// class SupplierListScreen extends ConsumerStatefulWidget {
//   const SupplierListScreen({super.key});
//
//   @override
//   ConsumerState<SupplierListScreen> createState() =>
//       _SupplierListScreenState();
// }
//
// class _SupplierListScreenState extends ConsumerState<SupplierListScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';
//
//   Future<void> _refreshData() async {
//     ref.invalidate(supplierProvider);
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
//     ref.listen<AsyncValue<void>>(supplierActionProvider, (previous, next) {
//       next.whenOrNull(
//         data: (_) {
//           if (!mounted) return;
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Action completed successfully!'),
//               backgroundColor: Colors.green,
//             ),
//           );
//           ref.invalidate(supplierProvider);
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
//     final dataAsync = ref.watch(supplierProvider);
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
//                       hintText: 'Search suppliers...',
//                       onChanged: (value) {
//                         setState(() => _searchQuery = value);
//                       },
//                     ),
//                   ),
//
//                   // 🧾 Empty State
//                   if (filteredItems.isEmpty)
//                     const SliverFillRemaining(
//                       hasScrollBody: false,
//                       child: Center(child: Text('No matching suppliers.')),
//                     )
//                   else
//                   // 🧱 Supplier List
//                     SliverList.builder(
//                       itemCount: filteredItems.length,
//                       itemBuilder: (_, index) {
//                         final item = filteredItems[index];
//
//                         return SwipeableListTile<Supplier>(
//                           item: item,
//                           deleteConfirmMessage:
//                           'Are you sure you want to delete "${item.name}"?',
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => SupplierDetailScreen(data: item),
//                               ),
//                             );
//                           },
//                           onDelete: () async {
//                             if (item.id != null) {
//                               await ref
//                                   .read(supplierActionProvider.notifier)
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
//                               Text('Code: ${data.code}', style: const TextStyle(fontSize: 14)),
//                               // 👇 Only include null-safe checks where necessary
//                               if (data.contactNo.isNotEmpty)
//                                 Text('Phone: ${data.contactNo}', style: const TextStyle(fontSize: 14)),
//                               if (data.address.isNotEmpty)
//                                 Text('Address: ${data.address}',
//                                     style: const TextStyle(fontSize: 14)),
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
//             builder: (_) => const SupplierDetailScreen(),
//           ),
//         ),
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
//
// // import 'package:flutter/material.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import '../models/supplier_model.dart';
// // import '../providers/supplier_provider.dart';
// // import '../widgets/swipeable_list_tile.dart';
// // import 'supplier_detail_screen.dart';
// //
// // class SupplierListScreen extends ConsumerStatefulWidget {
// //   const SupplierListScreen({super.key});
// //
// //   @override
// //   ConsumerState<SupplierListScreen> createState() =>
// //       _SupplierListScreenState();
// // }
// //
// // class _SupplierListScreenState extends ConsumerState<SupplierListScreen> {
// //   Future<void> _refreshData() async {
// //     ref.invalidate(supplierProvider);
// //     await Future.delayed(const Duration(milliseconds: 300));
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     // ✅ Safe listener for CRUD action result
// //     ref.listen<AsyncValue<void>>(supplierActionProvider, (previous, next) {
// //       next.whenOrNull(
// //         data: (_) {
// //           if (!mounted) return;
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             const SnackBar(
// //               content: Text('Action completed successfully!'),
// //               backgroundColor: Colors.green,
// //             ),
// //           );
// //           ref.invalidate(supplierProvider); // refresh product list
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
// //     final dataAsync = ref.watch(supplierProvider);
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
// //                 return SwipeableListTile<Supplier>(
// //                   item: item,
// //                   deleteConfirmMessage:
// //                   'Are you sure you want to delete "${item.name}"?',
// //                   onTap: () {
// //                     Navigator.push(
// //                       context,
// //                       MaterialPageRoute(
// //                         builder: (_) =>
// //                             SupplierDetailScreen(data: item),
// //                       ),
// //                     );
// //                   },
// //                   onDelete: () async {
// //                     if (item.id != null) {
// //                       await ref
// //                           .read(supplierActionProvider.notifier)
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
// //                       ),
// //                       const SizedBox(height: 4),
// //                       Text('Code: ${data.code}',
// //                           style: const TextStyle(fontSize: 14)),
// //                       Text('Address: ${data.address}',
// //                           style: const TextStyle(fontSize: 14)),
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
// //             builder: (_) => const SupplierDetailScreen(),
// //           ),
// //         ),
// //         child: const Icon(Icons.add),
// //       ),
// //     );
// //   }
// // }
