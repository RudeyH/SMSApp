import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_group_model.dart';
import '../providers/product_group_provider.dart';
import '../widgets/swipeable_list_tile.dart';

class ProductGroupLookupScreen extends ConsumerStatefulWidget {
  const ProductGroupLookupScreen({super.key});

  @override
  ConsumerState<ProductGroupLookupScreen> createState() =>
      _ProductGroupLookupScreenState();
}

class _ProductGroupLookupScreenState extends ConsumerState<ProductGroupLookupScreen> {
  final TextEditingController _searchController = TextEditingController();

  Future<void> _refreshData() async {
    ref.invalidate(productGroupProvider);
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    final asyncProductGroups = ref.watch(productGroupProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Product Group')),
      body: Column(
        children: [
          // 🔍 Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by code or name...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          // 📋 ProductGroup list
          Expanded(
            child: asyncProductGroups.when(
              data: (productGroups) {
                final query = _searchController.text.toLowerCase();

                final filteredProductGroups = productGroups.where((c) {
                  return c.code.toLowerCase().contains(query) ||
                      c.name.toLowerCase().contains(query);
                }).toList();

                if (filteredProductGroups.isEmpty) {
                  return const Center(
                    child: Text('No productGroup match your search.'),
                  );
                }

                return RefreshIndicator(
                  color: Colors.blueAccent,
                  onRefresh: _refreshData,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: filteredProductGroups.length,
                    itemBuilder: (context, index) {
                      final c = filteredProductGroups[index];

                      return SwipeableListTile<ProductGroup>(
                        item: c,
                        enableDelete: false, // 👈 disables swipe-to-delete
                        onTap: () {
                          Navigator.pop(context, {
                            'productGroupId': c.id,
                            'productGroup': c,
                            'productGroupName': c.name,
                          });
                        },
                        // You can leave onDelete null if lookup shouldn’t delete
                        onDelete: () async {
                          if (c.id != null) {
                            await ref
                                .read(productGroupActionProvider.notifier)
                                .deleteData(c.id!);
                            ref.invalidate(productGroupProvider);
                          }
                        },
                        contentBuilder: (_, data) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${data.code} - ${data.name}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}