import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';

class EditProductDialog extends StatefulWidget {
  final Product product;
  final VoidCallback onSave;

  const EditProductDialog({
    super.key,
    required this.product,
    required this.onSave,
  });

  @override
  State<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _materialsController;
  late TextEditingController _conditionController;
  late TextEditingController _quantityController;
  late TextEditingController _sizeController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.product.price.toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.product.description ?? '',
    );
    _materialsController = TextEditingController(
      text: widget.product.materials ?? '',
    );
    _conditionController = TextEditingController(
      text: widget.product.condition ?? '',
    );
    _quantityController = TextEditingController(
      text: widget.product.quantity.toString(),
    );
    _sizeController = TextEditingController(text: widget.product.size ?? '');
  }

  @override
  void dispose() {
    _priceController.dispose();
    _descriptionController.dispose();
    _materialsController.dispose();
    _conditionController.dispose();
    _quantityController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updates = {
        'price': double.parse(_priceController.text),
        'description': _descriptionController.text,
        'materials': _materialsController.text,
        'condition': _conditionController.text,
        'quantity': int.parse(_quantityController.text),
        'size': _sizeController.text,
      };

      await ProductService.updateProduct(widget.product.id, updates);

      if (mounted) {
        Navigator.pop(context);
        widget.onSave();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product updated successfully!'),
            backgroundColor: Color(0xFFEDFF00),
            behavior: SnackBarBehavior.floating,
            showCloseIcon: true,
            closeIconColor: Colors.black,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _buildInputDecoration(String label, {String? prefixText}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixText: prefixText,
      prefixStyle: const TextStyle(color: Colors.white),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white30),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFEDFF00)),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
      border: const OutlineInputBorder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Text(
        'Edit ${widget.product.name}',
        style: const TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _priceController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Price', prefixText: '₱ '),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (double.tryParse(value) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sizeController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Size'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _materialsController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Materials'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _conditionController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Condition'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantityController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (int.tryParse(value) == null) return 'Invalid number';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEDFF00),
            foregroundColor: Colors.black,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
              : const Text(
                  'Save',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }
}
