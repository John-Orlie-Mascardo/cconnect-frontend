import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // for image picking
import 'dart:io'; // needed to display picked images
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../services/product_service.dart';

// Use a runtime base URL that works for web and mobile platforms
// Web uses localhost, Android emulator uses 10.0.2.2
// For physical devices, replace with your machine LAN IP (e.g. http://192.168.1.42:3000/api)
// String get kApiBaseUrl {
//   if (kIsWeb) {
//     // Web platform - use localhost
//     return 'http://localhost:3000/api';
//   } else if (defaultTargetPlatform == TargetPlatform.android) {
//     // Android emulator - use 10.0.2.2 to reach host machine
//     return 'http://10.0.2.2:3000/api';
//   } else {
//     // iOS simulator or other platforms - use localhost
//     return 'http://localhost:3000/api';
//   }
// }

// a form widget for adding a new product
class AddProductForm extends StatefulWidget {
  const AddProductForm({super.key});

  @override
  State<AddProductForm> createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  // initialize all controllers for the form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _productIDController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final List<int> _selectedSizes = []; // stores selected sizes
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _materialsController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  dynamic _selectedImage; // to store selected image file mobile or web
  String? _selectedImagePath; //stores filename for upload
  final ImagePicker _picker = ImagePicker(); // image picker instance
  bool _isLoading = false; // loading state for save button

  // focus nodes for each field (if needed for advanced focus management)
  final List<FocusNode> _focusNodes = List.generate(7, (_) => FocusNode());

  // error messages for each field (if needed for validation)
  final List<String?> _errors = List.filled(8, null);

  // Scroll controller to auto-scroll to errors
  final ScrollController _scrollController = ScrollController();

  // opens gallery and stores image (mobile) or image bytes (web)
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      if (kIsWeb) {
        // web platform: store as bytes
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImage = bytes;
          _selectedImagePath = pickedFile.name;
        });
      } else {
        // mobile platform: store as file
        setState(() {
          _selectedImage = File(pickedFile.path);
          _selectedImagePath = pickedFile.path;
        });
      }
    }
  }

  // validates all fields and focuses/scrolls to first error
  bool _validateFields() {
    // clear previous errors
    setState(() {
      for (int i = 0; i < _errors.length; i++) {
        _errors[i] = null;
      }
    });

    bool isValid = true;
    int? firstErrorIndex;

    // validate each field in order
    final validations = [
      // 0: name
      _nameController.text.trim().isEmpty ? 'Product name is required' : null,
      // 1: product ID
      // 4: description
      _descriptionController.text.trim().isEmpty
          ? 'Description is required'
          : null,
      // 5: materials
      _materialsController.text.trim().isEmpty
          ? 'Materials are required'
          : null,
      // 6: condition
      _conditionController.text.trim().isEmpty ? 'Condition is required' : null,
      // 7: quantity
      () {
        if (_quantityController.text.trim().isEmpty) {
          return 'Quantity is required';
        }
        final qty = int.tryParse(_quantityController.text.trim());
        if (qty == null || qty < 0) return 'Quantity must be 0 or greater';
        return null;
      }(),
    ];

    // check for errors and track first one
    for (int i = 0; i < validations.length; i++) {
      if (validations[i] != null) {
        _errors[i] = validations[i];
        firstErrorIndex ??= i;
        isValid = false;
      }
    }

    // check image separately
    if (_selectedImage == null) {
      isValid = false;
      // show dialog since image picker isn't a text field
      if (firstErrorIndex == null) {
        // image is the first error
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text('Image Required', style: TextStyle(color: Colors.white)),
              content: const Text('Please select a product image.', style: TextStyle(color: Colors.white70)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK', style: TextStyle(color: Color(0xFFEDFF00))),
                ),
              ],
            ),
          );
        });
      }
    }

    if (firstErrorIndex != null) {
      // scroll to error
      _scrollController.animateTo(
        firstErrorIndex * 80.0, // approx height of field
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      // focus
      _focusNodes[firstErrorIndex].requestFocus();
    }

    return isValid;
  }

  Future<void> _saveProduct() async {
    if (!_validateFields()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final uri = Uri.parse('${ProductService.kApiBaseUrl}/products');
      final request = http.MultipartRequest('POST', uri);

      request.fields['name'] = _nameController.text.trim();
      request.fields['productId'] = _productIDController.text.trim();
      request.fields['price'] = _priceController.text.trim();
      request.fields['description'] = _descriptionController.text.trim();
      request.fields['materials'] = _materialsController.text.trim();
      request.fields['condition'] = _conditionController.text.trim();
      request.fields['quantity'] = _quantityController.text.trim();
      request.fields['sizes'] = _selectedSizes.join(','); // Send sizes as comma-separated string

      // Add image
      if (_selectedImage != null) {
        if (kIsWeb) {
          // Web: add from bytes
          request.files.add(
            http.MultipartFile.fromBytes(
              'image',
              _selectedImage,
              filename: _selectedImagePath ?? 'image.jpg',
            ),
          );
        } else {
          // Mobile: add from file path
          request.files.add(
            await http.MultipartFile.fromPath('image', _selectedImage.path),
          );
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success - show modal
        _showSuccessDialog();
      } else {
        // API error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: ${response.statusCode}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Network error
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // show success modal and closes form
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFFEDFF00), size: 64),
            const SizedBox(height: 20),
            const Text(
              'Success!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Product saved successfully',
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx); // Close dialog
                  Navigator.pop(context); // Close form
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEDFF00),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // textfield widgets
  }

  @override
  void dispose() {
    // disposing controllers to avoid memory leak
    _nameController.dispose();
    _productIDController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _materialsController.dispose();
    _conditionController.dispose();
    _quantityController.dispose();

    // dispose focus nodes
    for (var node in _focusNodes) {
      node.dispose();
    }

    // dispose error scroll controller
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        // for scrollability
        controller:
            _scrollController, // attach scroll controller to scroll view
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add New Product',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // add image section
            const SizedBox(height: 20),
            Focus(
              canRequestFocus: false, // prevent focus on container
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    // container decoration
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white30),
                  ),
                  child:
                      _selectedImage ==
                          null // if an image is selected, show it
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 40,
                              color: Colors.white70,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap to add product photo',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        )
                      : ClipRRect(
                          // else show placeholder
                          borderRadius: BorderRadius.circular(8),
                          child: kIsWeb
                              ? Image.memory(_selectedImage!, fit: BoxFit.cover)
                              : Image.file(_selectedImage!, fit: BoxFit.cover),
                        ),
                ),
              ),
            ),
            // Product Name field
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              focusNode: _focusNodes[0], // index 0 = name
              textInputAction: TextInputAction.next, // move to next field
              onSubmitted: (_) => _focusNodes[1].requestFocus(),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Product Name',
                labelStyle: const TextStyle(color: Colors.white70),
                errorText: _errors[0], // show error if any
                errorStyle: const TextStyle(color: Colors.redAccent),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFEDFF00)),
                ),
              ),
              onChanged: (_) =>
                  setState(() => _errors[0] = null), // clear error on change
            ),
            // Product ID field
            SizedBox(height: 20),
            TextField(
              controller: _productIDController,
              focusNode: _focusNodes[1], // index 1 = product ID
              textInputAction: TextInputAction.next, // move to next field
              onSubmitted: (_) => _focusNodes[2].requestFocus(),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Product ID',
                labelStyle: TextStyle(color: Colors.white70),
                errorText: _errors[1], // show error if any
                errorStyle: const TextStyle(color: Colors.redAccent),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFEDFF00)),
                ),
              ),
              onChanged: (_) => setState(() => _errors[1] = null),
            ),
            // Price field
            SizedBox(height: 20),
            TextField(
              controller: _priceController,
              focusNode: _focusNodes[2], // index 2 = price
              textInputAction: TextInputAction.next, // move to next field
              onSubmitted: (_) => _focusNodes[3].requestFocus(),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Price',
                prefixText: '₱ ',
                prefixStyle: const TextStyle(color: Colors.white),
                labelStyle: TextStyle(color: Colors.white70),
                errorText: _errors[2], // show error if any
                errorStyle: const TextStyle(color: Colors.redAccent),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFEDFF00)),
                ),
              ),
              onChanged: (_) => setState(() => _errors[2] = null),
            ),
            // Description field
            SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              focusNode: _focusNodes[3], // index 3 = description
              textInputAction: TextInputAction.next, // move to next field
              onSubmitted: (_) => _focusNodes[4].requestFocus(),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.white70),
                errorText: _errors[4], // show error if any
                errorStyle: const TextStyle(color: Colors.redAccent),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFEDFF00)),
                ),
              ),
              onChanged: (_) => setState(() => _errors[4] = null),
            ),
            // Materials field
            SizedBox(height: 20),
            TextField(
              controller: _materialsController,
              focusNode: _focusNodes[4], // index 4 = materials
              textInputAction: TextInputAction.next, // move to next field
              onSubmitted: (_) => _focusNodes[5].requestFocus(),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Materials',
                labelStyle: TextStyle(color: Colors.white70),
                errorText: _errors[5], // show error if any
                errorStyle: const TextStyle(color: Colors.redAccent),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFEDFF00)),
                ),
              ),
              onChanged: (_) => setState(() => _errors[5] = null),
            ),
            // Condition field
            SizedBox(height: 20),
            TextField(
              controller: _conditionController,
              focusNode: _focusNodes[5], // index 5 = condition
              textInputAction: TextInputAction.next, // move to next field
              onSubmitted: (_) => _focusNodes[6].requestFocus(),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Condition',
                labelStyle: TextStyle(color: Colors.white70),
                errorText: _errors[6], // show error if any
                errorStyle: const TextStyle(color: Colors.redAccent),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFEDFF00)),
                ),
              ),
              onChanged: (_) => setState(() => _errors[6] = null),
            ),
            // Quantity field
            SizedBox(height: 20),
            TextField(
              controller: _quantityController,
              focusNode: _focusNodes[6], // index 6 = quantity
              textInputAction: TextInputAction.done, // move to next field
              onSubmitted: (_) => _saveProduct(),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Quantity',
                labelStyle: TextStyle(color: Colors.white70),
                errorText: _errors[7], // show error if any
                errorStyle: const TextStyle(color: Colors.redAccent),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFEDFF00)),
                ),
              ),
              onChanged: (_) => setState(() => _errors[7] = null),
            ),
            // Size field
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Available Sizes', style: TextStyle(color: Colors.white70)),
                    const SizedBox(width: 10),
                    if (_errors[3] != null)
                      Text(_errors[3]!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(9, (index) {
                    final size = index + 4; // Sizes 4-12
                    final isSelected = _selectedSizes.contains(size);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedSizes.remove(size); // Deselect
                          } else {
                            _selectedSizes.add(size); // Select
                          }
                          _errors[3] = null; // Clear error when user interacts
                        });
                      },
                      child: Container(
                        width: 60,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFEDFF00)
                              : Colors.grey[800],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFEDFF00)
                                : Colors.grey[700]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            size.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEDFF00),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        'Save Product',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
