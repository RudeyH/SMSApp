import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/purchase_order_model.dart';
import '../providers/product_provider.dart';
import '../providers/purchase_order_provider.dart';
import '../widgets/swipeable_list_tile.dart';
import '../widgets/sticky_search_bar.dart';
import 'purchase_order_detail_screen.dart';

class PurchaseOrderListScreen extends ConsumerStatefulWidget {
  const PurchaseOrderListScreen({super.key});

  @override
  ConsumerState<PurchaseOrderListScreen> createState() =>
      _PurchaseOrderListScreenState();
}

class _PurchaseOrderListScreenState
    extends ConsumerState<PurchaseOrderListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final notifier = ref.read(purchaseOrderProvider.notifier);
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
    final dataAsync = ref.watch(purchaseOrderProvider);
    final notifier = ref.read(purchaseOrderProvider.notifier);
    return Scaffold(
      body: SafeArea(
        child: dataAsync.when(
          data: (items) => RefreshIndicator(
            onRefresh: notifier.refresh,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // 🔍 Sticky Search Bar
                SliverAppBar(
                  pinned: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  automaticallyImplyLeading: false,
                  elevation: 2,
                  titleSpacing: 0,
                  title: StickySearchBar(
                    controller: _searchController,
                    hintText: 'Search by number or supplier...',
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
                          horizontal: 16, vertical: 8),
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
                            onSelected: notifier.toggleSort,
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'transNumber',
                                child: Text('Transaction No.'),
                              ),
                              const PopupMenuItem(
                                value: 'transDate',
                                child: Text('Date'),
                              ),
                              const PopupMenuItem(
                                value: 'supplier',
                                child: Text('Supplier'),
                              ),
                              const PopupMenuItem(
                                value: 'grandTotal',
                                child: Text('Total Amount'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 📦 Purchase Order List
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

                    final order = items[index];
                    return SwipeableListTile<PurchaseOrder>(
                      item: order,
                      deleteConfirmMessage:
                      'Delete purchase order "${order.transNumber}"?',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PurchaseOrderDetailScreen(data: order),
                          ),
                        );
                      },
                      onDelete: () async {
                        if (order.id != null) {
                          final result = await ref.read(purchaseOrderActionProvider.notifier).deleteData(order.id!);
                          ref.invalidate(productProvider);
                          return result;
                        }
                        return null;
                      },
                      contentBuilder: (_, data) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.transNumber,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text('Supplier: ${data.supplier.name}'),
                          Text(
                            'Date: ${data.transDate.toLocal().toString().split(' ')[0]}',
                          ),
                          Text(
                            'Total: Rp ${data.grandTotal.toStringAsFixed(2)}',
                          ),
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
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const PurchaseOrderDetailScreen(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// 📌 Sticky Header Delegate (same as in ProductListScreen)
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
