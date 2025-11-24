import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../helpers/notification_helper.dart';
import '../models/customer_model.dart';
import '../providers/customer_provider.dart';

class CustomerDetailScreen extends ConsumerStatefulWidget {
  final Customer? data;

  const CustomerDetailScreen({super.key, this.data});

  @override
  ConsumerState<CustomerDetailScreen> createState() =>
      _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen> {
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
    ref.listen(
      customerActionProvider,
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
    final actionState = ref.watch(customerActionProvider);

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
                decoration: const InputDecoration(labelText: 'Customer Code'),
                readOnly: isEditing,
                validator: (value) =>
                value!.isEmpty ? 'Please enter a code' : null,
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Customer Name'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Customer Address'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter an address' : null,
              ),
              TextFormField(
                controller: _contactNoController,
                decoration: const InputDecoration(labelText: 'Supplier Contact No'),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                ],
                validator: validatePhoneIndonesia,
              ),
              const SizedBox(height: 24),
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final product = Customer(
      id: widget.data?.id ?? 0,
      code: _codeController.text.trim(),
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      contactNo: _contactNoController.text.trim(),
    );

    final notifier = ref.read(customerActionProvider.notifier);

    try {
      if (isEditing) {
        await notifier.updateData(product);
      } else {
        await notifier.createData(product);
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      showError(e.toString());
    }
  }

  String? validatePhoneIndonesia(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a contact number';
    }
    final cleaned = value.replaceAll(RegExp(r'[^0-9+]'), '');
    // +62xxxxxxxxxx
    if (RegExp(r'^\+62[0-9]{8,13}$').hasMatch(cleaned)) {
      return null;
    }
    // 62xxxxxxxxxx (no +)
    if (RegExp(r'^62[0-9]{8,13}$').hasMatch(cleaned)) {
      return null;
    }
    // 08xxxxxxxxxx
    if (RegExp(r'^0[0-9]{9,13}$').hasMatch(cleaned)) {
      return null;
    }
    return 'Invalid Indonesian phone number format';
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
