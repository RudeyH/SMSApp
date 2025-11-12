import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/supplier_provider.dart';

class SupplierLookupScreen extends ConsumerWidget {
  const SupplierLookupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSuppliers = ref.watch(supplierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Supplier')),
      body: asyncSuppliers.when(
        data: (suppliers) => ListView.builder(
          itemCount: suppliers.length,
          itemBuilder: (context, index) {
            final c = suppliers[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: ListTile(
                title: Text('${c.code} - ${c.name}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Address: ${c.address}'),
                    Text('Contact: ${c.contactNo}'),
                  ],
                ),
                onTap: () {
                  // Return selected supplier back to previous screen
                  Navigator.pop(context, {
                    'supplierId': c.id,
                    'supplier' : c,
                    'supplierName': c.name,
                  });
                },
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
