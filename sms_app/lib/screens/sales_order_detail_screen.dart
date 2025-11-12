import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../models/customer_model.dart';
import '../models/sales_order_item_model.dart';
import '../models/sales_order_model.dart';
import '../providers/sales_order_provider.dart';
import '../reports/sales_order_invoice_pdf.dart';
import 'customer_lookup_screen.dart';
import 'product_lookup_screen.dart';

class SalesOrderDetailScreen extends ConsumerStatefulWidget {
  final SalesOrder? data;

  const SalesOrderDetailScreen({super.key, this.data});

  @override
  ConsumerState<SalesOrderDetailScreen> createState() =>
      _SalesOrderDetailScreenState();
}

class _SalesOrderDetailScreenState
    extends ConsumerState<SalesOrderDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _transNumberController;
  int? _customerId;
  Customer? _customer;
  late TextEditingController _customerNameController;
  late DateTime transDate;
  late List<SalesOrderItem> items;
  bool get isEditing => widget.data != null;

  @override
  void initState() {
    super.initState();

    _transNumberController = TextEditingController(
      text: widget.data?.transNumber ?? 'SO-${DateTime.now().millisecondsSinceEpoch}',
    );

    _customerId = widget.data?.customerId ?? 0;
    _customer = widget.data?.customer; // ✅ no default Customer object

    _customerNameController = TextEditingController(
      text: widget.data?.customer.name ?? '',
    );

    transDate = widget.data?.transDate ?? DateTime.now();
    items = widget.data?.items ?? [];
  }


  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(salesOrderActionProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditing
                    ? 'Data updated successfully!'
                    : 'Data created successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        },
        error: (error, _) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $error'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    });

    final actionState = ref.watch(salesOrderActionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Data' : 'Add Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _transNumberController,
                decoration: const InputDecoration(labelText: 'Transaction Number'),
                readOnly: true,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _selectCustomer, // 👈 open lookup on tap
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _customerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Customer',
                      suffixIcon: Icon(Icons.search),
                    ),
                    validator: (value) => value!.isEmpty
                        ? 'Please select a customer'
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      'Date: ${transDate.toLocal().toString().split(' ')[0]}'),
                  Text('Total: ${totalAmount.toStringAsFixed(2)}'),
                ],
              ),
              const Divider(height: 20),
              Expanded(
                child: items.isEmpty
                    ? const Center(
                  child: Text('No items added yet'),
                )
                    : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      title: Text(item.product.name),
                      subtitle: Text(
                          'Qty: ${item.quantity} × ${item.unitPrice.toStringAsFixed(2)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeItem(item),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
                onPressed: _addItem,
              ),
              const SizedBox(height: 12),
              actionState.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                icon: Icon(isEditing ? Icons.save : Icons.add),
                label: Text(isEditing ? 'Update Data' : 'Save Data'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final data = SalesOrder(
                      id: widget.data?.id,
                      transNumber: _transNumberController.text,
                      transDate: transDate,
                      customerId: _customerId ?? 0,
                      customer: _customer ?? Customer(id: 0, code: '', name: '', address: '', contactNo: ''),
                      grandTotal: totalAmount,
                      items: items,
                    );

                    final notifier =
                    ref.read(salesOrderActionProvider.notifier);
                    if (isEditing) {
                      notifier.updateData(data);
                    } else {
                      notifier.createData(data);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: isEditing && items.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: _printInvoice,
        icon: const Icon(Icons.print),
        label: const Text('Print Invoice'),
        backgroundColor: Colors.blueAccent,
      )
          : null,
    );
  }

  @override
  void dispose() {
    _transNumberController.dispose();
    _customerNameController.dispose();
    super.dispose();
  }

  Future<void> _selectCustomer() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CustomerLookupScreen()),
    );

    if (result != null && mounted) {
      setState(() {
        _customerId = result['customerId'];
        _customer = result['customer'];
        _customerNameController.text = result['customerName'];
      });
    }
  }

  Future<void> _addItem() async {
    final newItem = await Navigator.push<SalesOrderItem>(
      context,
      MaterialPageRoute(builder: (_) => const ProductLookupScreen(source: 'sales')),
    );
    if (newItem != null) {
      setState(() {
        items.add(newItem);
      });
    }
  }

  void _removeItem(SalesOrderItem item) {
    setState(() {
      items.remove(item);
    });
  }

  double get totalAmount =>
      items.fold(0, (sum, item) => sum + (item.quantity * item.unitPrice));

  Future<void> _printInvoice() async {
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No items to print')),
      );
      return;
    }

    final pdfItems = items.map((e) {
      return SalesOrderItemPrint(
        code: e.product.code,
        name: e.product.name,
        qty: e.quantity.toInt(),
        unit: 'Pcs',
        price: e.unitPrice,
      );
    }).toList();

    final pdfData = await generateSalesOrderInvoice(
      customerName: _customerNameController.text.isEmpty
          ? 'Unknown Customer'
          : _customerNameController.text,
      transNumber: _transNumberController.text,
      transDate: transDate,
      dueDate: transDate.add(const Duration(days: 14)),
      items: pdfItems,
    );

    await Printing.layoutPdf(onLayout: (format) async => pdfData);
  }
}
