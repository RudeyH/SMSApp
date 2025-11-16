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
