import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/customer_model.dart';
import '../providers/customer_provider.dart';
import '../widgets/swipeable_list_tile.dart';

class CustomerLookupScreen extends ConsumerStatefulWidget {
  const CustomerLookupScreen({super.key});

  @override
  ConsumerState<CustomerLookupScreen> createState() =>
      _CustomerLookupScreenState();
}

class _CustomerLookupScreenState extends ConsumerState<CustomerLookupScreen> {
  final TextEditingController _searchController = TextEditingController();

  Future<void> _refreshData() async {
    ref.invalidate(customerProvider);
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    final asyncCustomers = ref.watch(customerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Customer')),
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

          // 📋 Customer list
          Expanded(
            child: asyncCustomers.when(
              data: (customers) {
                final query = _searchController.text.toLowerCase();

                final filteredCustomers = customers.where((c) {
                  return c.code.toLowerCase().contains(query) ||
                      c.name.toLowerCase().contains(query);
                }).toList();

                if (filteredCustomers.isEmpty) {
                  return const Center(
                    child: Text('No customers match your search.'),
                  );
                }

                return RefreshIndicator(
                  color: Colors.blueAccent,
                  onRefresh: _refreshData,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final c = filteredCustomers[index];

                      return SwipeableListTile<Customer>(
                        item: c,
                        enableDelete: false, // 👈 disables swipe-to-delete
                        onTap: () {
                          Navigator.pop(context, {
                            'customerId': c.id,
                            'customer': c,
                            'customerName': c.name,
                          });
                        },
                        // You can leave onDelete null if lookup shouldn’t delete
                        onDelete: () async {
                          if (c.id != null) {
                            await ref
                                .read(customerActionProvider.notifier)
                                .deleteData(c.id!);
                            ref.invalidate(customerProvider);
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
                            const SizedBox(height: 4),
                            Text('Address: ${data.address}',
                                style: const TextStyle(fontSize: 14)),
                            Text('Contact: ${data.contactNo}',
                                style: const TextStyle(fontSize: 14)),
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

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../providers/customer_provider.dart';
//
// class CustomerLookupScreen extends ConsumerWidget {
//   const CustomerLookupScreen({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final asyncCustomers = ref.watch(customerProvider);
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Select Customer')),
//       body: asyncCustomers.when(
//         data: (customers) => ListView.builder(
//           itemCount: customers.length,
//           itemBuilder: (context, index) {
//             final c = customers[index];
//             return Card(
//               margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//               elevation: 2,
//               child: ListTile(
//                 title: Text('${c.code} - ${c.name}',
//                     style: const TextStyle(
//                         fontWeight: FontWeight.bold, fontSize: 16)),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('Address: ${c.address}'),
//                     Text('Contact: ${c.contactNo}'),
//                   ],
//                 ),
//                 onTap: () {
//                   // Return selected customer back to previous screen
//                   Navigator.pop(context, {
//                     'customerId': c.id,
//                     'customer' : c,
//                     'customerName': c.name,
//                   });
//                 },
//               ),
//             );
//           },
//         ),
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (e, _) => Center(child: Text('Error: $e')),
//       ),
//     );
//   }
// }
