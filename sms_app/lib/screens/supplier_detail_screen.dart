import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/supplier_model.dart';
import '../providers/supplier_provider.dart';

class SupplierDetailScreen extends ConsumerStatefulWidget {
  final Supplier? data;

  const SupplierDetailScreen({super.key, this.data});

  @override
  ConsumerState<SupplierDetailScreen> createState() =>
      _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends ConsumerState<SupplierDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _contactNoController;

  bool get isEditing => widget.data != null;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.data?.code ?? '');
    _nameController = TextEditingController(text: widget.data?.name ?? '');
    _addressController = TextEditingController(text: widget.data?.address ?? '');
    _contactNoController = TextEditingController(text: widget.data?.contactNo ?? '');
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Safe placement for ref.listen
    ref.listen<AsyncValue<void>>(supplierActionProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditing
                    ? 'Supplier updated successfully!'
                    : 'Supplier created successfully!',
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

    final actionState = ref.watch(supplierActionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Supplier' : 'Add Supplier'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Supplier Code'),
                readOnly: isEditing,
                validator: (value) =>
                value!.isEmpty ? 'Please enter a code' : null,
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Supplier Name'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Supplier Address'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter an address' : null,
              ),
              TextFormField(
                controller: _contactNoController,
                decoration: const InputDecoration(labelText: 'Supplier Contact No'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter a contact no' : null,
              ),
              const SizedBox(height: 24),
              actionState.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                icon: Icon(isEditing ? Icons.save : Icons.add),
                label: Text(isEditing ? 'Update Supplier' : 'Save Supplier'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final product = Supplier(
                      id: widget.data?.id ?? 0,
                      code: _codeController.text.trim(),
                      name: _nameController.text.trim(),
                      address: _addressController.text.trim(),
                      contactNo: _contactNoController.text.trim(),
                    );

                    final notifier =
                    ref.read(supplierActionProvider.notifier);
                    if (isEditing) {
                      notifier.updateData(product);
                    } else {
                      notifier.createData(product);
                    }
                  }
                },
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
    _addressController.dispose();
    _contactNoController.dispose();
    super.dispose();
  }
}
