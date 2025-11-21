import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // for image picking
import 'dart:io'; // needed to display picked images
import 'dart:convert';
import 'package:http/http.dart' as http;

// Use a runtime base URL so Android emulator uses 10.0.2.2 automatically.
// For physical devices, replace with your machine LAN IP (e.g. http://192.168.1.42:3000/api)
final String kApiBaseUrl =
  Platform.isAndroid ? 'http://10.0.2.2:3000/api' : 'http://localhost:3000/api';

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
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _materialsController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  //
  File? _selectedImage; // store the selected image file (null if none selected)
  final ImagePicker _picker = ImagePicker(); // image picker instance
  bool _isLoading = false; // loading state for form submission

  Future<void> _pickImage() async {
    // main image picking function
    final XFile? pickedFiles = await _picker.pickImage(
      source: ImageSource.gallery,
    ); // opens gallery

    if (pickedFiles != null) {
      // if an image is picked
      setState(() {
        _selectedImage = File(pickedFiles.path); // store selected image file
      });
    }
  }

  // TODO: Backend - Replace this with actual API call
  // Available data to send:
  // - Product Name: _nameController.text
  // - Product ID: _productIDController.text
  // - Price: _priceController.text
  // - Size: _sizeController.text
  // - Description: _descriptionController.text
  // - Materials: _materialsController.text
  // - Condition: _conditionController.text
  // - Quantity: _quantityController.text
  // - Image file: _selectedImage (File? - can be null)
  //
  // On success: Keep the success SnackBar and Navigator.pop()
  // On error: Show error SnackBar instead, you can copy what I did for success SnackBar for reference

  // AFTER THIS (Backend Developer - Ken & John Orlie) tasks:
  //Create API endpoints for:

  // POST /products - Save new product (receives data from the form you built)
  // GET /products - Fetch all products for display
  // PUT /products/:id - Update existing product
  // DELETE /products/:id - Remove product

  // Connect the form - Replace the Future.delayed(...) in _saveProduct() with actual API call that sends the 8 fields + image to MongoDB

  // Frontend Developer (Joshua Austria & John Orlie) tasks:

  // Display products on homepage - Replace the hardcoded demoProducts list in home_screen.dart with products fetched from the backend API
  // Products Management screen updates:

  // Replace empty state with a list of products (when products exist)
  // Each product card should have Edit and Delete buttons

  // Edit functionality:

  // Tapping Edit opens the same AddProductForm but pre-filled with existing product data
  // Change "Add New Product" title to "Edit Product"
  // Change "Save Product" button logic to call PUT instead of POST

  // Delete functionality:

  // Tapping Delete shows a confirmation dialog ("Are you sure?")
  // If confirmed, call DELETE API and remove from list
  // ---------------------------------------------------------------
  // ADDITIONAL FEATURES SUGGESTIONS:
  // Critical (do these next):

  // Form validation - Don't let owner save if required fields (Name, Price, Quantity) are empty
  // Error handling - Show error message if API call fails (network issues, server down)
  // Loading state on Products screen - Show spinner while fetching products from backend

  // Nice to have (later):

  // Search/filter products - Let owner find products quickly as inventory grows
  // Product details page - Tap a product to see full info (currently just shows in grid)
  // Low stock alerts - Highlight products with quantity < 5
  // ---------------------------------------------------------------

  Future<void> _saveProduct() async {
    // show loading indicator
    setState(() {
      _isLoading = true;
    });

    final uri = Uri.parse('$kApiBaseUrl/products');

    try {
      http.Response response;
      debugPrint('POST -> $uri');

      // If an image is selected, use multipart request
      if (_selectedImage != null) {
        final request = http.MultipartRequest('POST', uri);
        request.fields['name'] = _nameController.text;
        request.fields['productId'] = _productIDController.text;
        request.fields['price'] = _priceController.text;
        request.fields['size'] = _sizeController.text;
        request.fields['description'] = _descriptionController.text;
        request.fields['materials'] = _materialsController.text;
        request.fields['condition'] = _conditionController.text;
        request.fields['quantity'] = _quantityController.text;
        request.files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));

        final streamed = await request.send();
        response = await http.Response.fromStream(streamed);
        debugPrint('Multipart response: ${response.statusCode} ${response.body}');
      } else {
        // Otherwise send JSON body
        final body = {
          'name': _nameController.text,
          'productId': _productIDController.text,
          'price': _priceController.text,
          'size': _sizeController.text,
          'description': _descriptionController.text,
          'materials': _materialsController.text,
          'condition': _conditionController.text,
          'quantity': _quantityController.text,
        };

        debugPrint('JSON POST body: ${jsonEncode(body)}');
        response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );
        debugPrint('JSON response: ${response.statusCode} ${response.body}');
      }

      // hide loading indicator
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // close the form
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save product: ${response.statusCode} ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
    _sizeController.dispose();
    _descriptionController.dispose();
    _materialsController.dispose();
    _conditionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        // for scrollability
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
            const SizedBox(height: 16),
            // add image section
            const SizedBox(height: 16),
            GestureDetector(
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
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      ),
              ),
            ),
            // Product Name field
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Product Name',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFEDFF00)),
                ),
              ),
            ),
            // Product ID field
            TextField(
              controller: _productIDController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Product ID',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFEDFF00)),
                ),
              ),
            ),
            // Price field
            TextField(
              controller: _priceController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Price',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFEDFF00)),
                ),
              ),
            ),
            // Size field
            TextField(
              controller: _sizeController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Size',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFEDFF00)),
                ),
              ),
            ),
            // Description field
            TextField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFEDFF00)),
                ),
              ),
            ),
            // Materials field
            TextField(
              controller: _materialsController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Materials',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFEDFF00)),
                ),
              ),
            ),
            // Condition field
            TextField(
              controller: _conditionController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Condition',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFEDFF00)),
                ),
              ),
            ),
            // Quantity field
            TextField(
              controller: _quantityController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Quantity',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFEDFF00)),
                ),
              ),
            ),
            const SizedBox(height: 24),
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
