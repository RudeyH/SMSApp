import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../enums/app_enums.dart';
import '../helpers/notification_helper.dart';
import '../models/supplier_model.dart';
import '../models/purchase_order_item_model.dart';
import '../models/purchase_order_model.dart';
import '../providers/product_provider.dart';
import '../providers/purchase_order_provider.dart';
import 'supplier_lookup_screen.dart';
import 'product_lookup_screen.dart';

class PurchaseOrderDetailScreen extends ConsumerStatefulWidget {
  final PurchaseOrder? data;

  const PurchaseOrderDetailScreen({super.key, this.data});

  @override
  ConsumerState<PurchaseOrderDetailScreen> createState() =>
      _PurchaseOrderDetailScreenState();
}

class _PurchaseOrderDetailScreenState
    extends ConsumerState<PurchaseOrderDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _transNumberController;
  int? _supplierId;
  Supplier? _supplier;
  late TextEditingController _supplierNameController;
  late DateTime transDate;
  late List<PurchaseOrderItem> items;
  bool get isEditing => widget.data != null;

  @override
  void initState() {
    super.initState();
    _transNumberController =
        TextEditingController(text: widget.data?.transNumber ?? 'PO');
    _supplierId = widget.data?.supplierId ?? 0;
    _supplier = widget.data?.supplier;
    _supplierNameController = TextEditingController(text: widget.data?.supplier.name ?? '');
    transDate = widget.data?.transDate ?? DateTime.now();
    items = widget.data?.items ?? [];
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      purchaseOrderActionProvider,
          (previous, next) {
        next.whenOrNull(
          data: (result) {
            if (result != null) {
              showSuccess(result.message);
            }
          },
          error: (err, _) {
            showError(err.toString());
          },
        );
      },
    );

    final actionState = ref.watch(purchaseOrderActionProvider);

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
                onTap: _selectSupplier, // 👈 open lookup on tap
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _supplierNameController,
                    decoration: const InputDecoration(
                      labelText: 'Supplier',
                      suffixIcon: Icon(Icons.search),
                    ),
                    validator: (value) => value!.isEmpty
                        ? 'Please select a supplier'
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectTransDate,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Date: ${transDate.year}-'
                                    '${transDate.month.toString().padLeft(2, '0')}-'
                                    '${transDate.day.toString().padLeft(2, '0')}',
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Total: ${totalAmount.toStringAsFixed(2)}',
                  ),
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
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectTransDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: transDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && mounted) {
      setState(() {
        transDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
        );
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (isEditing &&
        (widget.data?.id == null || widget.data!.id == 0)) {
      showError('Cannot update purchase order: ID is missing.');
      return;
    }

    final String transNumber = isEditing
        ? widget.data!.transNumber
        : _generateTransNumber(
      DateTime(
        transDate.year,
        transDate.month,
        transDate.day,
        DateTime.now().hour,
        DateTime.now().minute,
        DateTime.now().second,
      ),
    );

    final savedData = PurchaseOrder(
      id: widget.data?.id,
      transNumber: transNumber,
      transDate: transDate,
      supplierId: _supplierId ?? 0,
      supplier: _supplier ?? Supplier(id: 0, code: '', name: '', address: '', contactNo: ''),
      grandTotal: totalAmount,
      items: items,
    );

    final notifier = ref.read(purchaseOrderActionProvider.notifier);

    try {
      if (isEditing) {
        await notifier.updateData(savedData);
      } else {
        await notifier.createData(savedData);
      }
      if (!mounted) return;
      ref.invalidate(productProvider);
      Navigator.pop(context, true);
    } catch (e) {
      showError(e.toString());
    }
  }

  Future<void> _selectSupplier() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SupplierLookupScreen()),
    );

    if (result != null && mounted) {
      setState(() {
        _supplierId = result['supplierId'];
        _supplier = result['supplier'];
        _supplierNameController.text = result['supplierName'];
      });
    }
  }

  Future<void> _addItem() async {
    final newItem = await Navigator.push<PurchaseOrderItem>(
      context,
      MaterialPageRoute(builder: (_) => const ProductLookupScreen(mode: ProductLookupMode.purchase,)),
    );
    if (newItem != null) {
      setState(() {
        items.add(newItem);
      });
    }
  }

  void _removeItem(PurchaseOrderItem item) {
    setState(() {
      items.remove(item);
    });
  }

  String _generateTransNumber(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final second = date.second.toString().padLeft(2, '0');

    return 'PO-$year$month$day$hour$minute$second';
  }

  double get totalAmount =>
      items.fold(0, (sum, item) => sum + (item.quantity * item.unitPrice));

  @override
  void dispose() {
    _transNumberController.dispose();
    _supplierNameController.dispose();
    super.dispose();
  }

}
