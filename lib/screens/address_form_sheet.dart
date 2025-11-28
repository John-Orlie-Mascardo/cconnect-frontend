import 'package:flutter/material.dart';
import '../models/address.dart';

/// Form sheet for adding or editing user addresses
///
/// This widget handles both add and edit modes:
/// - Add mode: existingAddress is null
/// - Edit mode: existingAddress contains the address to modify
///
/// Backend integration points:
/// - The onSave callback receives the completed Address object
/// - Parent screen is responsible for calling the appropriate API endpoint
class AddressFormSheet extends StatefulWidget {
  final Address? existingAddress; // null = add new, not null = edit existing
  final Function(Address) onSave;

  const AddressFormSheet({
    super.key,
    this.existingAddress,
    required this.onSave,
  });

  @override
  State<AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers for each field
  late TextEditingController _provinceCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _barangayCtrl;
  late TextEditingController _postalCodeCtrl;
  late TextEditingController _streetDetailsCtrl;

  // Focus nodes for keyboard navigation
  final List<FocusNode> _focusNodes = List.generate(5, (_) => FocusNode());
  // Index mapping:
  // 0: Province, 1: City, 2: Barangay, 3: Postal Code, 4: Street Details

  bool _isDefault = false;

  @override
  void initState() {
    super.initState();

    // If editing existing address, pre-fill the fields
    final addr = widget.existingAddress;
    _provinceCtrl = TextEditingController(text: addr?.province ?? '');
    _cityCtrl = TextEditingController(text: addr?.city ?? '');
    _barangayCtrl = TextEditingController(text: addr?.barangay ?? '');
    _postalCodeCtrl = TextEditingController(text: addr?.postalCode ?? '');
    _streetDetailsCtrl = TextEditingController(text: addr?.streetDetails ?? '');
    _isDefault = addr?.isDefault ?? false;
  }

  @override
  void dispose() {
    // Clean up controllers and focus nodes to prevent memory leaks
    _provinceCtrl.dispose();
    _cityCtrl.dispose();
    _barangayCtrl.dispose();
    _postalCodeCtrl.dispose();
    _streetDetailsCtrl.dispose();

    for (var node in _focusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  /// Validates form and returns completed Address object to parent
  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final address = Address(
      id: widget.existingAddress?.id, // Preserve existing ID when editing
      province: _provinceCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      barangay: _barangayCtrl.text.trim(),
      postalCode: _postalCodeCtrl.text.trim(),
      streetDetails: _streetDetailsCtrl.text.trim(),
      isDefault: _isDefault,
    );

    widget.onSave(address); // Parent handles API call
    Navigator.pop(context); // Close form
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Form title (changes based on add/edit mode)
              Text(
                widget.existingAddress == null ? 'Add Address' : 'Edit Address',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Province field
              _buildTextField(
                _provinceCtrl,
                'Province',
                focusNode: _focusNodes[0],
                onSubmitted: (_) => _focusNodes[1].requestFocus(),
              ),

              // City field
              _buildTextField(
                _cityCtrl,
                'City',
                focusNode: _focusNodes[1],
                onSubmitted: (_) => _focusNodes[2].requestFocus(),
              ),

              // Barangay field
              _buildTextField(
                _barangayCtrl,
                'Barangay',
                focusNode: _focusNodes[2],
                onSubmitted: (_) => _focusNodes[3].requestFocus(),
              ),

              // Postal Code field
              _buildTextField(
                _postalCodeCtrl,
                'Postal Code',
                focusNode: _focusNodes[3],
                onSubmitted: (_) => _focusNodes[4].requestFocus(),
              ),

              // Street Details field (multiline, last field)
              _buildTextField(
                _streetDetailsCtrl,
                'Street Name, Building, House No.',
                maxLines: 2,
                focusNode: _focusNodes[4],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(), // Save when pressing done
              ),

              // Default address checkbox
              CheckboxListTile(
                title: const Text(
                  'Set as Default Address',
                  style: TextStyle(color: Colors.white),
                ),
                value: _isDefault,
                onChanged: (val) => setState(() => _isDefault = val ?? false),
                activeColor: const Color(0xFFEDFF00),
                checkColor: Colors.black,
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 16),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEDFF00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save Address',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Reusable text field builder with validation and focus management
  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    Function(String)? onSubmitted,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        maxLines: maxLines,
        textInputAction: textInputAction ?? TextInputAction.next,
        onFieldSubmitted: onSubmitted,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white30),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFEDFF00)),
          ),
          errorStyle: const TextStyle(color: Colors.redAccent),
        ),
        validator: (val) =>
            val == null || val.trim().isEmpty ? 'This field is required' : null,
      ),
    );
  }
}
