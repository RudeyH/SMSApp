import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/uom_model.dart';
import '../providers/uom_provider.dart';
import '../widgets/swipeable_list_tile.dart';

class UomLookupScreen extends ConsumerStatefulWidget {
  const UomLookupScreen({super.key});

  @override
  ConsumerState<UomLookupScreen> createState() =>
      _UomLookupScreenState();
}

class _UomLookupScreenState extends ConsumerState<UomLookupScreen> {
  final TextEditingController _searchController = TextEditingController();

  Future<void> _refreshData() async {
    ref.invalidate(uomProvider);
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    final asyncUoms = ref.watch(uomProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Uom')),
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

          // 📋 Uom list
          Expanded(
            child: asyncUoms.when(
              data: (uoms) {
                final query = _searchController.text.toLowerCase();

                final filteredUoms = uoms.where((c) {
                  return c.code.toLowerCase().contains(query) ||
                      c.name.toLowerCase().contains(query);
                }).toList();

                if (filteredUoms.isEmpty) {
                  return const Center(
                    child: Text('No uom match your search.'),
                  );
                }

                return RefreshIndicator(
                  color: Colors.blueAccent,
                  onRefresh: _refreshData,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: filteredUoms.length,
                    itemBuilder: (context, index) {
                      final c = filteredUoms[index];

                      return SwipeableListTile<UOM>(
                        item: c,
                        enableDelete: false, // 👈 disables swipe-to-delete
                        onTap: () {
                          Navigator.pop(context, {
                            'uomId': c.id,
                            'uom': c,
                            'uomName': c.name,
                          });
                        },
                        // You can leave onDelete null if lookup shouldn’t delete
                        onDelete: () async {
                          if (c.id != null) {
                            await ref
                                .read(uomActionProvider.notifier)
                                .deleteData(c.id!);
                            ref.invalidate(uomProvider);
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