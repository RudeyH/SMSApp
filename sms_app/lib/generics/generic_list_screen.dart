import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'generic_list_config.dart';
import 'generic_list_providers.dart';
import '../widgets/sticky_search_bar.dart';
import '../widgets/swipeable_list_tile.dart';

class GenericListScreen<T> extends ConsumerStatefulWidget {
  final GenericListConfig<T> config;

  const GenericListScreen({
    super.key,
    required this.config,
  });

  @override
  ConsumerState<GenericListScreen<T>> createState() =>
      _GenericListScreenState<T>();
}

class _GenericListScreenState<T> extends ConsumerState<GenericListScreen<T>> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      final provider = genericListProvider(widget.config);
      final notifier = ref.read(provider.notifier);

      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        notifier.loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final listProvider = genericListProvider(widget.config);
    final actionProvider = genericActionProvider(widget.config);

    final dataAsync = ref.watch(listProvider);
    final notifier = ref.read(listProvider.notifier);

    return Scaffold(
      floatingActionButton: widget.config.addScreenBuilder == null
          ? null
          : FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => widget.config.addScreenBuilder!()),
        ),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: dataAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => Center(child: Text(err.toString())),
          data: (items) => RefreshIndicator(
            onRefresh: notifier.refresh,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  pinned: true,
                  titleSpacing: 0,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  title: StickySearchBar(
                    controller: _searchController,
                    hintText: "Search...",
                    onChanged: notifier.search,
                  ),
                ),

                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyHeaderDelegate(
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(notifier.sortLabel),
                          PopupMenuButton<String>(
                            onSelected: notifier.toggleSort,
                            itemBuilder: (_) => widget.config.sortFields.keys
                                .map(
                                  (f) => PopupMenuItem(
                                value: f,
                                child: Text(f),
                              ),
                            )
                                .toList(),
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                SliverList.builder(
                  itemCount: items.length + 1,
                  itemBuilder: (ctx, i) {
                    if (i == items.length) {
                      if (notifier.hasMore) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: Text("End of list")),
                      );
                    }

                    final item = items[i];

                    return SwipeableListTile<T>(
                      item: item,
                      onDelete: () async {
                        final id = (item as dynamic).id;

                        final msg = await ref
                            .read(actionProvider.notifier)
                            .deleteData(id);

                        if (msg != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(msg)),
                          );
                        }

                        notifier.refresh();
                      },
                      onTap: () {
                        widget.config.onTap?.call(context, item);
                      },
                      contentBuilder: widget.config.itemBuilder,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  double get minExtent => 40;
  @override
  double get maxExtent => 40;

  @override
  Widget build(_, __, ___) => child;

  @override
  bool shouldRebuild(_) => false;
}
