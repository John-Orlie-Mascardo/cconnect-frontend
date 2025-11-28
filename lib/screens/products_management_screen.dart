import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'add_product_form.dart';

import '../services/product_service.dart';

// runtime API base URL (Android emulator uses 10.0.2.2)
// String get kApiBaseUrl {
//   if (kIsWeb) return 'http://localhost:3000/api';
//   if (defaultTargetPlatform == TargetPlatform.android)
//     return 'http://10.0.2.2:3000/api';
//   return 'http://localhost:3000/api';
// }

class ProductsManagementScreen extends StatefulWidget {
  // product managemement screen
  const ProductsManagementScreen({super.key});

  @override
  State<ProductsManagementScreen> createState() => _ProductsManagementScreen();
}

// main products page
class _ProductsManagementScreen extends State<ProductsManagementScreen> {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final uri = Uri.parse('${ProductService.kApiBaseUrl}/products');
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        // assume data is an array
        setState(() {
          _products = List<Map<String, dynamic>>.from(
            data,
          ).where((p) => p['deleted'] != true).toList();
        });
      } else {
        debugPrint('Failed to fetch products: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteProduct(String id) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text(
              'Remove product?',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'This will mark the product as removed.',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    try {
      final uri = Uri.parse('${ProductService.kApiBaseUrl}/products/$id');
      final res = await http.delete(uri);
      if (res.statusCode == 200 || res.statusCode == 204) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Product removed')));
        await _fetchProducts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Remove failed: ${res.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> product) async {
    final nameController = TextEditingController(text: product['name']);
    final priceController = TextEditingController(
      text: product['price'].toString(),
    );
    final descriptionController = TextEditingController(
      text: product['description'],
    );
    final materialsController = TextEditingController(
      text: product['materials'],
    );
    final conditionController = TextEditingController(
      text: product['condition'],
    );
    final quantityController = TextEditingController(
      text: product['quantity'].toString(),
    );
    final stockController = TextEditingController(
      text: product['stock'].toString(),
    );

    // Parse existing sizes
    Set<int> selectedSizes = {};
    if (product['sizes'] != null && product['sizes'] is List) {
      selectedSizes = (product['sizes'] as List)
          .map((e) => int.parse(e.toString()))
          .toSet();
    } else if (product['size'] != null) {
      // Fallback for old string format
      final parts = product['size'].toString().split(',');
      for (var part in parts) {
        final s = int.tryParse(part.trim());
        if (s != null) selectedSizes.add(s);
      }
    }

    final availableSizes = [4, 5, 6, 7, 8, 9, 10, 11, 12];

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text(
              'Edit Product',
              style: TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                    ),
                  ),
                  TextField(
                    controller: priceController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                    ),
                  ),
                  TextField(
                    controller: descriptionController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                    ),
                  ),
                  TextField(
                    controller: materialsController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Materials',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                    ),
                  ),
                  TextField(
                    controller: conditionController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Condition',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                    ),
                  ),
                  TextField(
                    controller: quantityController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                    ),
                  ),
                  TextField(
                    controller: stockController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Stock',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Sizes',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableSizes.map((size) {
                      final isSelected = selectedSizes.contains(size);
                      return FilterChip(
                        label: Text(size.toString()),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              selectedSizes.add(size);
                            } else {
                              selectedSizes.remove(size);
                            }
                          });
                        },
                        backgroundColor: Colors.grey[800],
                        selectedColor: const Color(0xFFEDFF00),
                        checkmarkColor: Colors.black,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFFEDFF00)
                                : Colors.grey[700]!,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final uri = Uri.parse(
                      '${ProductService.kApiBaseUrl}/products/${product['_id']}',
                    );
                    final response = await http.put(
                      uri,
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({
                        'name': nameController.text,
                        'price': double.tryParse(priceController.text) ?? 0.0,
                        'description': descriptionController.text,
                        'materials': materialsController.text,
                        'condition': conditionController.text,
                        'quantity': int.tryParse(quantityController.text) ?? 0,
                        'stock': int.tryParse(stockController.text) ?? 0,
                        'sizes': selectedSizes.join(
                          ',',
                        ), // Send as comma-separated string
                      }),
                    );

                    if (response.statusCode == 200) {
                      Navigator.pop(ctx);
                      _fetchProducts(); // Refresh list
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Product updated successfully'),
                        ),
                      );
                    } else {
                      throw Exception('Failed to update: ${response.body}');
                    }
                  } catch (e) {
                    print('Error updating product: $e');
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEDFF00),
                  foregroundColor: Colors.black,
                ),
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // top bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.black,
              child: Row(
                children: [
                  // back button
                  InkWell(
                    splashColor: Colors.white24,
                    highlightColor: Colors.white24,
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 16),
                          const Icon(
                            Icons.inventory_2_outlined,
                            size: 80,
                            color: Colors.white,
                          ),
                          const Text(
                            'No products added yet',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'kobe11',
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchProducts,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final p = _products[index];
                          final imageName = p['image'] as String?;
                          // Backend now returns full path like /uploads/filename.jpg
                          final imageUrl =
                              (imageName != null && imageName.isNotEmpty)
                              ? '${ProductService.kApiBaseUrl.replaceAll('/api', '')}$imageName'
                              : null;

                          return Card(
                            color: Colors.grey[900],
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 96,
                                    height: 96,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.black,
                                      image: imageUrl != null
                                          ? DecorationImage(
                                              image: NetworkImage(imageUrl),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: imageUrl == null
                                        ? const Icon(
                                            Icons.image_not_supported,
                                            color: Colors.white24,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p['name'] ?? 'No name',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Price: ${p['price'] ?? '-'}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Qty: ${p['quantity'] ?? p['stock'] ?? '-'} • Cond: ${p['condition'] ?? '-'}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            ElevatedButton(
                                              onPressed: () =>
                                                  _showEditDialog(p),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFFEDFF00,
                                                ),
                                                foregroundColor: Colors.black,
                                              ),
                                              child: const Text('Update'),
                                            ),
                                            const SizedBox(width: 8),
                                            ElevatedButton(
                                              onPressed: () => _deleteProduct(
                                                p['_id']?.toString() ??
                                                    p['id']?.toString() ??
                                                    '',
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.grey[800],
                                                foregroundColor: Colors.white,
                                              ),
                                              child: const Text('Remove'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFEDFF00),
        onPressed: () async {
          // item add pop up form
          await showModalBottomSheet(
            // modal screen background color
            backgroundColor: const Color.fromARGB(255, 27, 27, 27),
            context: context,
            builder: (context) {
              return const AddProductForm();
            },
          );
          // refresh when sheet is closed
          await _fetchProducts();
        },
        // add item icon
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
