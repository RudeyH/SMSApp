import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sms_app/screens/uom_lookup_screen.dart';
import '../models/product_model.dart';
import '../models/uom_model.dart';
import '../providers/product_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final Product? data;

  const ProductDetailScreen({super.key, this.data});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;
  int? _uomId;
  UOM? _uom;
  late TextEditingController _uomNameController;
  bool get isEditing => widget.data != null;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.data?.code ?? '');
    _nameController = TextEditingController(text: widget.data?.name ?? '');
    _priceController =
        TextEditingController(text: widget.data?.price.toString() ?? '');
    _quantityController =
        TextEditingController(text: widget.data?.quantity.toString() ?? '');
    _uomId = widget.data?.uomId ?? 0;
    _uom = widget.data?.uom; // ✅ no default Uom object
    _uomNameController = TextEditingController(
      text: widget.data?.uom.name ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(productActionProvider, (previous, next) {
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

    final actionState = ref.watch(productActionProvider);

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
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Product Code'),
                readOnly: isEditing,
                validator: (value) =>
                value!.isEmpty ? 'Please enter a code' : null,
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? 'Please enter the price' : null,
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? 'Please enter the quantity' : null,
              ),
              const SizedBox(height: 24),
              actionState.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                icon: Icon(isEditing ? Icons.save : Icons.add),
                label: Text(isEditing ? 'Update Data' : 'Save Data'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final product = Product(
                      id: widget.data?.id ?? 0,
                      code: _codeController.text.trim(),
                      name: _nameController.text.trim(),
                      price: double.tryParse(
                          _priceController.text.trim()) ??
                          0,
                      quantity: double.tryParse(
                          _quantityController.text.trim()) ??
                          0,
                      uomId: _uomId ?? 0,
                      uom: _uom ?? UOM(id: 0, code: '', name: ''),
                    );

                    final notifier =
                    ref.read(productActionProvider.notifier);
                    if (isEditing) {
                      notifier.updateData(product);
                    } else {
                      notifier.createData(product);
                    }
                  }
                },
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _selectUom, // 👈 open lookup on tap
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _uomNameController,
                    decoration: const InputDecoration(
                      labelText: 'Uom',
                      suffixIcon: Icon(Icons.search),
                    ),
                    validator: (value) => value!.isEmpty
                        ? 'Please select a uom'
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _uomNameController.dispose();
    super.dispose();
  }

  Future<void> _selectUom() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UomLookupScreen()),
    );

    if (result != null && mounted) {
      setState(() {
        _uomId = result['uomId'];
        _uom = result['uom'];
        _uomNameController.text = result['uomName'];
      });
    }
  }
}
