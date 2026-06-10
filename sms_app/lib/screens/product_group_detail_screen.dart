import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../helpers/notification_helper.dart';
import '../models/product_group_model.dart';
import '../providers/product_group_provider.dart';

class ProductGroupDetailScreen extends ConsumerStatefulWidget {
  final ProductGroup? data;

  const ProductGroupDetailScreen({super.key, this.data});

  @override
  ConsumerState<ProductGroupDetailScreen> createState() =>
      _ProductGroupDetailScreenState();
}

class _ProductGroupDetailScreenState extends ConsumerState<ProductGroupDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _nameController;

  bool get isEditing => widget.data != null;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.data?.code ?? '');
    _nameController = TextEditingController(text: widget.data?.name ?? '');
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      productGroupActionProvider,
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

    final actionState = ref.watch(productGroupActionProvider);

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
                decoration: const InputDecoration(labelText: 'Product Group Code'),
                readOnly: isEditing,
                validator: (value) =>
                value!.isEmpty ? 'Please enter a code' : null,
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Group Name'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter a name' : null,
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

    final savedData = ProductGroup(
      id: widget.data?.id ?? 0,
      code: _codeController.text.trim(),
      name: _nameController.text.trim(),
    );

    final notifier = ref.read(productGroupActionProvider.notifier);

    try {
      if (isEditing) {
        await notifier.updateData(savedData);
      } else {
        await notifier.createData(savedData);
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      showError(e.toString());
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
