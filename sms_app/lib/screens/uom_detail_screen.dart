import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/uom_model.dart';
import '../providers/uom_provider.dart';

class UomDetailScreen extends ConsumerStatefulWidget {
  final UOM? data;

  const UomDetailScreen({super.key, this.data});

  @override
  ConsumerState<UomDetailScreen> createState() =>
      _UomDetailScreenState();
}

class _UomDetailScreenState extends ConsumerState<UomDetailScreen> {
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
    // ✅ Safe placement for ref.listen
    ref.listen<AsyncValue<void>>(uomActionProvider, (previous, next) {
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

    final actionState = ref.watch(uomActionProvider);

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
                decoration: const InputDecoration(labelText: 'UOM Code'),
                readOnly: isEditing,
                validator: (value) =>
                value!.isEmpty ? 'Please enter a code' : null,
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'UOM Name'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 24),
              actionState.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                icon: Icon(isEditing ? Icons.save : Icons.add),
                label: Text(isEditing ? 'Update Data' : 'Save Data'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final data = UOM(
                      id: widget.data?.id ?? 0,
                      code: _codeController.text.trim(),
                      name: _nameController.text.trim(),
                    );

                    final notifier =
                    ref.read(uomActionProvider.notifier);
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
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
